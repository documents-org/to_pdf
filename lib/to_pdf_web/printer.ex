defmodule ToPdfWeb.Printer do
	@valid_types ["url", "html_body"]
	@printers ["webkit"]

	def check_body(params) do
		valid_input = Map.get(params, "type") in @valid_types
		input_data = Map.get(params, "data")
		printer = Map.get(params, "printer")
		if valid_input and is_binary(input_data) and printer do
			{:ok, %{
				email: Map.get(params, "email"),
				type: Map.get(params, "type") |> String.to_atom,
				data: Map.get(params, "data"),
				printer: Map.get(params, "printer"),
				printer_params: Map.get(params, "printer_params", %{}) }}
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

	def print(params) do
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

	def print_using_webkit(%{type: :html_body, data: data, printer_params: printer_params}) do
		case PdfGenerator.generate(data, shell_params: sanitized_webkit_params(printer_params)) do
			{:ok, filename} -> {:ok, filename}
			{:error, {_, message}} -> {:error, "Failed to convert to pdf with reason : " <> message}
		end
	end 

	def print_using_webkit(_), do: {:error, "Not Implemented"}
end