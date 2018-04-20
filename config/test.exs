use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chips, ChipsWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :chips, Chips.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER_NAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  hostname: "postgres-test",
  pool: Ecto.Adapters.SQL.Sandbox
