# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chips,
  ecto_repos: [Chips.Repo]

# Configures the endpoint
config :chips, ChipsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zCaN6FRMeBRrLcFT9heLp2iBlLT+EVXqaBCr91Xa0uIWUJVAkaBCjZXMlewoaxPU",
  render_errors: [view: ChipsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Chips.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :chips, ChipsWeb.Guardian,
  issuer: "Chips",
  secret_key: "EfTH8Dt8W0H9YesZFENt8MEiBWxuxFYce4MM2oDtbRF4twJ1CECzqZGyDrQifOXk",
  # optional
  allowed_algos: ["HS256"],
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
