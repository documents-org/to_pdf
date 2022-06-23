import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :argon2_elixir, t_cost: 1, m_cost: 8

# We don't run a server during test. If one is required,
# you can enable the server option below.

config :to_pdf, ToPdf.Repo,
  database: Path.expand("../to_pdf_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

config :to_pdf, ToPdfWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  server: false

# In test we don't send emails.
config :to_pdf, ToPdf.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
