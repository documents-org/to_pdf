defmodule ToPdfWeb.PrintController do
	use ToPdfWeb, :controller
	import Piper

	def print(conn, params) do
		process = to_pipable(params)
		|> pipe(&ToPdfWeb.AuthAgent.verify/1)
		|> pipe(&ToPdfWeb.Printer.check_body/1)
		|> pipe(&ToPdfWeb.Printer.print/1)
		|> IO.inspect()

		case process do
			{:ok, file_path, _} -> conn
				|> put_resp_content_type("application/pdf")
    			|> put_resp_header("content-disposition", "attachment; filename=output.pdf")
    			|> send_file(200, file_path)
			{:error, _, errors} -> conn
				|> send_resp(400, Enum.join(errors, "\n"))
		end
	end
end