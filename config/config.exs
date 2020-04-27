# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :app, AppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1KQnUP0lyOwHZCFn4ZMqt0FksBT0/gudlpNSJvuwuAvro7xBUuez4GEwxLUeQ4B9",
  render_errors: [view: AppWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: App.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

#- Config for the imager (you can put in dev or prod or here)
config :app, :imager,
  endpoints: %{
    "imager.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    "images.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    "cdn1.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    "cdn2.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    "cdn3.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    "cdn4.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    "dev.upyet.net" =>  %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/upyet"},
    "img.remarketforme.com" => %{url: " https://remarketforme.s3.amazonaws.com", storage: "/tmp/remarket"},
    "localhost" => %{url: " https://remarketforme.s3.amazonaws.com", storage: "/tmp/remarket"}
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
