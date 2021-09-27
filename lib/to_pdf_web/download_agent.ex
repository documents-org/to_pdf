defmodule ToPdfWeb.DownloadLink do
	defstruct used: 0, using: [], file: ""
end

defmodule ToPdfWeb.DownloadAgent do
	alias ToPdfWeb.DownloadLink

	use Agent

	@moduledoc """
	State takes this form :
	%{
		<download ID>? => %{ used: <integer < 5>, using: [<PID>], file: <file path>}
	}
	The download ID is stored as long as a download is valid.
	A download becomes invalid when its "used" counter reaches five.
	When someone starts downloading a file, the conn PID is stored in the "using" list.
	Periodically, we check if the PIDs exist. If they're dead, the connecion has been closed.
	When the last connection of a registered download link expires and its use counter
	has reached 5, it's unreacheable and we delete the file.
	"""

	def start_link() do
		ToPdfWeb.DownloadServer.start_link()
		Agent.start_link(fn -> %{} end, name: __MODULE__)
	end

	def start_maybe() do
		case GenServer.whereis(__MODULE__) do
			nil -> start_link()
			_ -> :ok
		end
	end

	@doc """
	Here we get a new download link ID.
	"""
	def register_download_link(file_path) do
		start_maybe()
		id = UUID.uuid4()
		Agent.update(__MODULE__, fn state -> Map.put(state, id, %DownloadLink{used: 0, using: [], file: file_path}) end)
		{:ok, id}
	end

	@doc """
	Is the file with this download id available ?
	"""
	def is_available_for_download?(id) do
		case Agent.get(__MODULE__, fn state -> Map.get(state, id) end) do
			nil -> false
			%DownloadLink{used: 5} -> false
			_ -> true
		end
	end

	@doc """
	Registers the conn PID with the downloaders of a file.
	"""
	def request_download(id, pid) do
		start_maybe()
		if is_available_for_download?(id) do
			file_path = Agent.get(__MODULE__, fn state -> Map.get(state, id) end) |> Map.get(:file)
			Agent.update(__MODULE__, fn state -> Map.update(state, id, %DownloadLink{}, fn %DownloadLink{used: ud, using: ug, file: f} ->
				%DownloadLink{used: ud + 1, using: [pid | ug], file: f}
			end) end)
			{:ok, file_path}
		else
			{:error, "File unavailable for download"}
		end
	end

	@doc """
	Two-pass purging : first, look for download links with more than 4 uses and nobody
	actively downloading it.

	Then, update pid lists by calling Process.alive?() on them.
	If they're dead of exiting, a long download has been done (or canceled).
	"""
	def purge_downloads() do
		Agent.update(__MODULE__, fn state ->
			state
			|>  Enum.filter(fn {_, %DownloadLink{used: used, using: using}} ->
					flag = (used > 4) and (length(using) == 0)
					!flag
				end)
			|> Enum.map(fn {key, %DownloadLink{using: using} = val} ->
				filtered_pids = using |> Enum.filter(fn pid -> Process.alive?(pid) end)
				new_val= val |> Map.put(:using, filtered_pids)
				{key, new_val}
				end)
			|> Enum.into(%{})
		end)
	end

	def refresh() do
		purge_downloads()
	end
end

