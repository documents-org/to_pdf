defmodule ToPdfWeb.AuthAgent do
	use Agent

	@config_file "~/.config/to_pdf/tokens"

	def initial_state() do
		tokens = case File.read(Path.expand(@config_file)) do
			{:ok, contents} -> String.split(contents, "\n") |> Enum.filter(fn a -> String.length(a) > 0 end)
			{:error, _} -> []
		end

		tokens |> Enum.reduce(%{}, fn (item, map) -> Map.put(map, String.trim(item), 1) end)
	end

	def start_link() do
		Agent.start_link(&initial_state/0, name: __MODULE__)
	end

	def start_maybe() do
		case GenServer.whereis(__MODULE__) do
			nil -> start_link()
			_ -> :ok
		end
	end

	def verify(params) do
		start_maybe()
		token = Map.get(params, "token")
	    if Mix.env() in [:dev, :test] do
	    	{:ok, params}
	    else
			case do_verify(token) do
				:ok -> {:ok, params}
				:error -> {:error, "Failed to authenticate the user"}
			end
		end
	end

	def do_verify(token) do
		case Agent.get(__MODULE__, fn a -> a end) |> Map.get(token) do
			nil -> :error
			_ -> :ok
		end
	end
end