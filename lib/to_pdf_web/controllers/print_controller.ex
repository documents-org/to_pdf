defmodule ToPdfWeb.PrintController do
	use ToPdfWeb, :controller
	import Piper

	def print(conn, params) do
		validated_params = to_pipable(params)
		|> pipe(&ToPdfWeb.AuthAgent.verify/1)
		|> pipe(&ToPdfWeb.Printer.check_body/1)
		
		case validated_params.email do
			nil -> print_and_send_file(conn, validated_params)
			_ -> print_and_notify(conn, validated_params)
		end
	end

	defp print_and_notify(conn, params) do
		pipe(params, &ToPdfWeb.Printer.async_print_and_notify/1)

		case params do
			{:ok, _, _} -> conn
    			|> send_resp(200, "PDF Job started")
			{:error, _, errors} -> conn
				|> send_resp(400, Enum.join(errors, "\n"))
		end
	end

	defp print_and_send_file(conn, params) do
		case ToPdfWeb.Printer.sync_print_and_send_back(params) do
			{:ok, file_path} -> do_download(conn, file_path)
			{:error, _} -> send_resp(400, "Error in handling your request")
		end
	end

	def download(conn, %{"id" => id}) do
		case ToPdfWeb.DownloadAgent.request_download(id, conn.owner) do
			{:ok, file_path} -> do_download(conn, file_path)
				

			{:error, reason} ->
				conn |> send_resp(400, "Error in handling your request")
		end
	end

	defp do_download(conn, file_path) do
		conn |> put_resp_content_type("application/pdf")
    	     |> put_resp_header("content-disposition", "attachment; filename=output.pdf")
    		 |> send_file(200, file_path)
	end
end