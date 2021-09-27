defmodule ToPdfWeb.DownloadServer do
	use GenServer

	@interval :timer.seconds(10)

	def start_link() do
		GenServer.start_link(ToPdfWeb.DownloadServer, name: __MODULE__)	
	end

	def init(init_arg) do
      {:ok, init_arg}
    end

	def handle_info(:refresh, a) do
		ToPdfWeb.DownloadAgent.refresh()
		Process.send_after(self(), :refresh, @interval)
		{:noreply, a}
	end
end