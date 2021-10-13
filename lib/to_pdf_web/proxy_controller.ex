defmodule ToPdfWeb.ProxyController do
	use ToPdfWeb, :controller

	def get_asset(conn, %{"id" => asset, "handler" => agent}) do
		pid = agent
			|> String.to_charlist
			|> :erlang.list_to_pid
		case GenServer.whereis(pid) do
			nil -> conn |> send_resp(404, "Failed to find an asset")
			pid -> conn |> send_file(200, ToPdfWeb.ProxyAgent.get_asset(pid, asset))
		end
	end
end