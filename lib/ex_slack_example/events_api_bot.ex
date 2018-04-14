defmodule ExSlackExample.EventsApiBot do
  use ExSlackEventsApiBot

  # Handles 'app_mention' event
  def handle_event(%{"type" => "app_mention"} = event, bot_state) do
    ExSlack.WebApi.Chat.post_message(bot_state.token, event["channel"], "Hey <@#{event["user"]}>!, what do you need from me?")
    {:ok, channel} = open_im(bot_state.token, event["user"])
    case ExSlack.WebApi.Channels.info(bot_state.token, event["channel"]) do
      {:ok, %{channel: original_channel}} ->
        ExSlack.WebApi.Chat.post_message(bot_state.token, channel.id, "Hi, I was mentioned by you in channel ##{original_channel.name}")
      {:error, _} ->
        ExSlack.WebApi.Chat.post_message(bot_state.token, channel.id, "Hi, I was mentioned by you in channel I couldn't get its name.")
    end
    :ok
  end

  # Handles a message (IM, public, private channels) from a bot
  # It is defined first to ignore all bot messages
  def handle_event(%{"type" => "message", "subtype" => "bot_message"} = event, state) do
    # Ignoring message from a bot
  end

  # Handles a message (IM, public, private channels) in a thread
  def handle_event(%{"type" => "message", "thread_ts" => thread_ts} = event, state) do
    ExSlack.WebApi.Chat.post_message(state.token, event["channel"], "Continuing the thread", thread_ts: thread_ts)
  end

  # This handles events from events: 'message.channels', 'message.in', 'message.groups'.
  # 'message.channels' - if bot is in a public channel
  # 'message.in' - a direct message in a DM channel
  # 'message.groups' - if bot is in a private channel
  def handle_event(%{"type" => "message"} = event, bot_state) do
    if event["text"] do
      cond do
        String.starts_with? event["text"], "echo:" ->
          ExSlack.WebApi.Chat.post_message(bot_state.token, event["channel"], "_echoing your message:_ #{String.slice(event["text"], 6..-1)}")
        String.starts_with? event["text"], "thread:" ->
          ExSlack.WebApi.Chat.post_message(bot_state.token, event["channel"], "Hey, let's start a thread", thread_ts: event["ts"])
        String.starts_with? event["text"], "ephemeral:" ->
          ExSlack.WebApi.Chat.post_ephemeral(bot_state.token, event["channel"], "This message is only visible to you", event["user"])
        String.starts_with? event["text"], "interactive:" ->
          ExSlack.WebApi.Chat.post_message(bot_state.token, event["channel"], "Let's play a game!", 
            attachments: Poison.encode!(create_interactive_message()))
        String.starts_with? event["text"], "dialog:" ->
          ExSlack.WebApi.Chat.post_message(bot_state.token, event["channel"], "Would you like to open a dialog?", 
            attachments: Poison.encode!(create_dialog_interactive_message()))
        true ->
          ExSlack.WebApi.Chat.post_message(bot_state.token, event["channel"], "I see a message from <@#{event["user"]}> in this channel.")
      end
    end
    :ok
  end

  def handle_interactive_message(%{"type" => "interactive_message", "callback_id" => "wopr_game", "actions" => actions} = payload, state) do
    action = hd actions
    ExSlack.WebApi.Chat.update(state.token, payload["channel"]["id"], ":ok:, Let's play *#{action["value"]}*.", payload["original_message"]["ts"],
      attachments: "{}")
  end

  def handle_interactive_message(%{"type" => "interactive_message", "callback_id" => "dialog_flow", "actions" => actions} = payload, state) do
    action = hd actions
    response = cond do
      action["value"] == "yes" ->
        ExSlack.WebApi.Chat.update(state.token, payload["channel"]["id"], ":ok:, cool.", payload["original_message"]["ts"],
          attachments: "{}")
        ExSlack.WebApi.Dialog.open(state.token, Poison.encode!(create_dialog_definition()), payload["trigger_id"])
      action["value"] == "no" ->
        ExSlack.WebApi.Chat.update(state.token, payload["channel"]["id"], ":ok:, No worries.", payload["original_message"]["ts"],
          attachments: "{}")
    end
    IO.inspect response, label: "Response"
  end

  def handle_interactive_message(%{"type" => "dialog_submission", "callback_id" => "dialog_flow", "submission" => submission} = payload, state) do
    ExSlack.WebApi.Chat.post_message(state.token, payload["channel"]["id"], "Ok, so your name is *#{submission["first_name"]} #{submission["last_name"]}*")
  end

  defp open_im(token, user_id) do
    {:ok, %{channel: channel}} = ExSlack.WebApi.Im.open(token, user_id)
    case ExSlack.WebApi.Channels.info(token, channel.id) do
      {:ok, %{channel: response_channel}} ->
        {:ok, response_channel}
      {:error, "channel_not_found"} ->
        ExSlack.WebApi.Im.close(token, channel.id)
        {:ok, %{channel: channel} = result} = ExSlack.WebApi.Im.open(token, user_id)
        {:ok, channel}
    end
  end

  defp create_dialog_interactive_message do
    [
      %{
        "text" => "Do you want to open a dialog?",
        "fallback" => "You are unable to open a dialog",
        "callback_id" => "dialog_flow",
        "color" => "#3AA3E3",
        "attachment_type" => "default",
        "actions" => [
          %{
            "name" => "dialog",
            "text" => "Yes",
            "type" => "button",
            "value" => "yes"
          },
          %{
            "name" => "dialog",
            "text" => "No",
            "type" => "button",
            "value" => "no"
          }
        ]
      }
    ]
  end

  defp create_interactive_message do
    [
      %{
        "text" => "Choose a game to play",
        "fallback" => "You are unable to choose a game",
        "callback_id" => "wopr_game",
        "color" => "#3AA3E3",
        "attachment_type" => "default",
        "actions" => [
          %{
            "name" => "game",
            "text" => "Chess",
            "type" => "button",
            "value" => "chess"
          },
          %{
            "name" => "game",
            "text" => "Falken's Maze",
            "type" => "button",
            "value" => "maze"
          },
          %{
            "name" => "game",
            "text" => "Thermonuclear War",
            "type" => "button",
            "value" => "war"
          }
        ]
      }
    ]
  end

  defp create_dialog_definition do
    %{
      "callback_id" => "dialog_flow",
      "title" => "Tell me your name",
      "submit_label" => "Request",
      "elements" => [
        %{
          "type" => "text",
          "label" => "First Name",
          "name" => "first_name"
        },
        %{
          "type" => "text",
          "label" => "Last Name",
          "name" => "last_name"
        }
      ]
    }
  end
end 