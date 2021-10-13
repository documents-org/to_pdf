defmodule ToPdfWeb.Printer do
	@valid_types ["url", "html_body"]
	@printers ["webkit"]
	@default_params %{
		"webkit" => [
            "--margin-left", "0",
            "--margin-right", "0",
            "--margin-top", "0",
            "--margin-bottom", "0",
            "--page-size", "A4",
            #"--dpi", "96",
            #"--image-dpi", "100",
            "--javascript-delay", "2000",
		],
	}
	def get_default_params(params) do
		Map.get(@default_params, Map.get(params, "printer"), [])	
	end
	
	def real_bool("true"), do: true
	def real_bool("false"), do: false

	def check_body(params) do
		valid_input = Map.get(params, "type") in @valid_types
		input_data = Map.get(params, "data")
		proxy = Map.get(params, "proxy", false) |> real_bool
		printer = Map.get(params, "printer")
		if valid_input and is_binary(input_data) and printer do
			{:ok, %{
				email: Map.get(params, "email"),
				type: Map.get(params, "type") |> String.to_atom,
				data: Map.get(params, "data"),
				proxy: proxy,
				printer: Map.get(params, "printer"),
				printer_params: Map.get(params, "printer_params", get_default_params(params)) }}
		else
			{:error, "Failed to find a complete body"}
		end 
	end

	def async_print_and_notify(params) do
		Task.start(fn () ->
			case print(params) do
				{:ok, filename} -> ToPdfWeb.Notifier.notify_success(params.email, filename) 
				{:error, _} -> ToPdfWeb.Notifier.notify_failure(params.email)	
			end
		end)
	end

	def sync_print_and_send_back(params) do
		print(params)
	end

	def print(params) do
		params = ToPdfWeb.Proxy.proxify(params)		
		valid_printer = params.printer in @printers
		if valid_printer do
			apply(__MODULE__, String.to_atom("print_using_" <> params.printer), [params])
		else
			{:error, "Failed to find a valid printing method in the request body"}
		end
	end

	def sanitized_webkit_params(input) do
		input
	end

	def print_using_webkit(%{type: :url, data: data, printer_params: printer_params}) do
		case HTTPoison.get(data) do
			{:ok, response} -> print_using_webkit(%{type: :html_body, data: response.body, printer_params: printer_params})
			_ -> {:error, "Failed to fetch the page."}
		end
	end

	def print_using_webkit(%{type: :html_body, data: data, printer_params: printer_params}) do
		case PdfGenerator.generate(data, shell_params: sanitized_webkit_params(printer_params)) do
			{:ok, filename} -> {:ok, filename}
			{:error, {_, message}} -> {:error, "Failed to convert to pdf with reason : " <> message}
		end
	end 

	def print_using_webkit(_), do: {:error, "Not Implemented"}
end