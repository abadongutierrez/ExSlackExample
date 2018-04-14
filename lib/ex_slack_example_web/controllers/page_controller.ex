defmodule ExSlackExampleWeb.PageController do
  use ExSlackExampleWeb, :controller

  alias ExSlack.EventsApiBot, as: Bot
  #alias ExSlack.WebBot, as: Bot

  def index(conn, _params) do
    render conn, "index.html", client_id: System.get_env("CLIENT_ID")
  end

  def thanks(conn, params) do
    if Map.has_key?(params, "code") do
      # IDEA: connect and start rtm? or handle events?
      # TODO: What about `Verification Token`?
      case Bot.start_link(System.get_env("CLIENT_ID"), System.get_env("CLIENT_SECRET"), params["code"], ExSlackExample.EventsApiBot) do
        {:ok, pid} ->
          IO.inspect pid, label: "New pid: "
          if Process.whereis(__MODULE__) != nil do
            Process.unregister(__MODULE__)
          end
          Process.register pid, __MODULE__
        {:error, reason} -> IO.puts "Error: #{reason}"
      end
    end
    render conn, "thanks.html"
  end

  def slack(conn, params) do
    # IDEA: ExSlack.EventHandler.handle_event(params)
    # ExSlack.WebBot.handle_event(pid, params)
    IO.inspect params, label: "Slack Event: "
    text_to_render = 
      cond do
        Map.has_key?(params, "type") and params["type"] == "url_verification" and Map.has_key?(params, "challenge") ->
          params["challenge"]
        Map.has_key?(params, "type") and params["type"] == "event_callback" and Map.has_key?(params, "event") ->
          pid = Process.whereis(__MODULE__)
          if pid != nil, do: Bot.process_event(pid, params["event"]), else: IO.puts "### No PID!"
          "Ok"
        true -> "Ok"
      end
    text conn, text_to_render
  end

  def event(conn, params) do
    cond do
      Map.has_key?(params, "payload")->
        payload = Poison.decode!(params["payload"])
        IO.inspect payload, label: "Slack Interactive Event: "
        pid = Process.whereis(__MODULE__)
        if pid != nil, do: Bot.process_interactive_message(pid, payload), else: IO.puts "### No PID!"
        "Ok"
      true -> "Ok"
    end
    conn
    |> send_resp(200, "")
  end
end
