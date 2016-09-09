# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :secure_messenger,
  ecto_repos: [SecureMessenger.Repo]

# Configures the endpoint
config :secure_messenger, SecureMessenger.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VT36kSFLs/gZppMshPFdlzhO4H97A4nY/DCZF7SafoI1JtLYjLUW/d6g3vOvZGv1",
  render_errors: [view: SecureMessenger.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SecureMessenger.PubSub,
           adapter: Phoenix.PubSub.Redis,
           url: System.get_env("REDIS_DATABASE_URL")]


 config :guardian, Guardian,
   allowed_algos: ["HS512"],
   verify_module: Guardian.JWT,
   issuer: "SecureMessenger",
   ttl: { 30, :days},
   verify_issuer: true,
   secret_key: "<your secret guardian key>",
   serializer: SecureMessenger.GuardianSerializer

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
