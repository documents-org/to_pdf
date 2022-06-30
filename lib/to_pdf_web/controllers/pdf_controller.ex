defmodule ToPdfWeb.PdfController do
	use ToPdfWeb, :controller

	def resample(conn, %{"dpi" => dpi, "file" => file, "token" => token}) do
    case ToPdfWeb.AuthAgent.do_verify(token) do
      :ok ->
          {:ok, resampled} = do_resample(file, dpi)
          conn |> put_resp_content_type("application/pdf")
            |> put_resp_header("content-disposition", "attachment; filename=output.pdf")
            |> send_file(200, resampled)
      :error
          -> send_resp(conn, 400, "Error in handling your request")
    end
	end

  def do_resample(%Plug.Upload{} = file, dpi) do
    int_dpi = String.to_integer(dpi)
    filename = ToPdfWeb.ProxyAgent.random_filename()
    command_args = ~w(-o #{filename} -sDEVICE=pdfwrite -dDownsampleColorImages=true -dDownsampleGrayImages=true -dDownsampleMonoImages=true -dColorImageResolution=#{int_dpi} -dGrayImageResolution=#{int_dpi} -dMonoImageResolution=#{int_dpi} -dColorImageDownsampleThreshold=1.0 -dGrayImageDownsampleThreshold=1.0 -dMonoImageDownsampleThreshold=1.0 #{file.path})
    case IO.inspect(System.cmd("gs", IO.inspect(command_args))) do
      {_, 0} -> {:ok, filename}
      _ -> {:error, "Failed to downsample"}
    end
  end
end
