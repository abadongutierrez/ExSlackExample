# ExSlackExample

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## What do you need?

* A Slack Workspace
* ngrok

## Setup your Slack App in your Workspace

* Create a new app in your Slack workspace.
* Give it a name, i.e., ExSlackApp
* Add a bot, i.e., exslackbot in `Bot Users`
* Get in `Basic Information` to get your `Client Id`, `Client Secret`, and `Verification Token`.
* Configure the redirect URL of this web app `/thanks` in `OAuth & Permissions` (here use the ngrok URL).
* Enable Events in `Event Subscriptions`
* Setup de request URL of this web app `/slack` in `Event Subscriptions` (here use the ngrok URL).
  * here the web app needs to be running because Slack sends a HTTP POST to this URL.
* Subscribe to Bot Events, for example, `message.in` for direct messages, or `message.channels` for messages in a public channel, or `message.groups` for messages in a private channel, or `app_mentions` for mentions of the bot in any kind of channel.
* Enable Interactive components and specify the Request URL to `/events` in `Interactive Components`.


# Run ExSlackExample

```
CLIENT_ID=<Your client id> CLIENT_SECRET=<Your client secret> VERIFICATION_TOKEN=<Your verification token> mix phx.server
```