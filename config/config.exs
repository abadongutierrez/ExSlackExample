# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ex_slack_example,
  ecto_repos: [ExSlackExample.Repo]

# Configures the endpoint
config :ex_slack_example, ExSlackExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "eJGt3j+G504FMl7iXkR+yyWYPALvSdPx1LEGHz94CvfsDCIkUw8YzxiILgqyz8SR",
  render_errors: [view: ExSlackExampleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExSlackExample.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
