defmodule ToPdfWeb.PrintController do
	use ToPdfWeb, :controller
	import Piper

	def print(conn, params) do
		process = to_pipable(params)
		|> pipe(&ToPdfWeb.AuthAgent.verify/1)
		|> pipe(&ToPdfWeb.Printer.check_body/1)
		
		pipe(process, &ToPdfWeb.Printer.async_print_and_notify/1)

		case process do
			{:ok, _, _} -> conn
    			|> send_resp(200, "PDF Job started")
			{:error, _, errors} -> conn
				|> send_resp(400, Enum.join(errors, "\n"))
		end
	end

	def download(conn, %{"id" => id}) do
		case ToPdfWeb.DownloadAgent.request_download(id, conn.owner) do
			{:ok, file_path} ->
				conn |> put_resp_content_type("application/pdf")
    			|> put_resp_header("content-disposition", "attachment; filename=output.pdf")
    			|> send_file(200, file_path)

			{:error, reason} ->
				conn |> send_resp(400, "Error in handling your request")
		end
	end
end