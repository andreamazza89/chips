use Mix.Config

config :chips, ChipsWeb.Endpoint,
  load_from_system_env: true,
  http: [port: "${PORT}"],
  check_origin: false,
  root: ".",
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

config :chips, Chips.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER_NAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  pool_size: 15
