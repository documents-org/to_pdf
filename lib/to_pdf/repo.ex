defmodule ToPdf.Repo do
  use Ecto.Repo,
    otp_app: :to_pdf,
    adapter: Ecto.Adapters.SQLite3
end
