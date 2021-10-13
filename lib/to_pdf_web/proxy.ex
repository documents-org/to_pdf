defmodule ToPdfWeb.ProxyAgent do
	use Agent
	@public_url System.get_env("TOPDF_PROXIFIED_URL")

	def start_link() do
		Agent.start_link(fn () -> %{} end)
	end

	def random_string() do
		chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" |> String.codepoints()
    	Enum.map_join(1..16, fn _ -> Enum.random(chars) end)
	end

	def random_filename() do
		Path.join(System.tmp_dir, random_string())
	end

	def proxy(agent, "http" <> _rest = url) do
		{:ok, response} = HTTPoison.get(url)
		filename = random_filename()
		id = random_string()
		File.write(filename, response.body)
		new_url = "#{@public_url}/asset/#{URI.encode(:erlang.pid_to_list(agent) |> to_string)}/#{id}"
		Agent.update(agent, fn state ->
			Map.put(state, id, filename)
		end)
		IO.inspect("Proxifying #{url} to #{new_url}")
		new_url
	end
	def proxy(_agent, url) do
		url
	end

	def get_asset(agent, id) do
		Agent.get(agent, fn state ->
			Map.get(state, id)
		end)
	end

	def clean(agent) do
		Agent.get(agent, fn a -> a end) |> Enum.each(fn {_, filename} ->
			File.rm(filename)
		end)
		Agent.stop(agent)
	end
end

defmodule ToPdfWeb.Proxy do
	def proxify(%{proxy: false} = params), do: params

	def proxify(%{proxy: true} = params) do
		html_body = case params.type do
			:html_body -> params.data
			:url -> {:ok, response} = HTTPoison.get(params.data)
				response.body
		end

		{:ok, document} = Floki.parse_document(html_body)

		{:ok, pid} = ToPdfWeb.ProxyAgent.start_link()

		new_body = Floki.traverse_and_update(document, fn (node) -> 
			case node do
				{tag, attributes, children} ->
					{tag, proxy_attributes(attributes, pid), children}
				_ -> node
			end
		end)
		|> Floki.raw_html

		params 
		|> Map.put(:data, new_body)
		|> Map.put(:type, :html_body)
	end

	def proxy_attributes(attributes, pid) do
		attributes |> Enum.map(fn {key, val} = attr ->
			case key do
				"src" -> {key, ToPdfWeb.ProxyAgent.proxy(pid, val)}
				"href" -> {key, ToPdfWeb.ProxyAgent.proxy(pid, val)}
				_ -> attr
			end
		end)
	end
end