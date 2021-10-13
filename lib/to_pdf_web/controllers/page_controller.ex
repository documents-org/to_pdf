defmodule ToPdfWeb.PageController do
  use ToPdfWeb, :controller

  def home(conn, _params) do
    render(conn, "index.html")
  end

  def health(conn, _) do
    conn |> send_resp(200, "running")
  end
end
