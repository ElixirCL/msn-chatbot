defmodule MsnChatbot do
  @moduledoc """
  A simple chatbot that connects MSN Messenger with ChatGPT
  """

  import Plug.Conn
  require Logger

  alias MsnChatbot.Memory
  alias MsnChatbot.Prelude

  alias OpenaiEx
  alias OpenaiEx.ChatCompletion, as: Chat
  alias OpenaiEx.ChatMessage, as: Message

  def hash(string) do
    :crypto.hash(:md5, string)
    |> Base.encode16(case: :lower)
  end

  def chat(bot, origin, message) do
    Logger.info("User <#{origin}> sent a message")

    key = hash(origin)
    Memory.set(key, Message.user(message))

    memory = Enum.take(Memory.get(key), 100)
    messages = Prelude.prelude() ++ memory

    operation = Chat.new(model: "gpt-3.5-turbo", messages: messages)
    response = Chat.create(bot, operation)

    case Map.get(response, "error") do
      nil ->
        answer =
          response["choices"]
          |> List.first()
          |> get_in(["message", "content"])

        Memory.set(key, Message.assistant(answer))
        answer

      error ->
        Logger.error("Response Error")
        Logger.error(error["type"])
        ":-* I can't answer right now. Please try later (B)."
    end
  end

  def init(options) do
    options
  end

  @doc """
  Simple route that returns a string
  """
  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _opts) do
    Logger.info("Got request")

    conn = Plug.Conn.fetch_query_params(conn)

    params = conn.query_params

    origin = Map.get(params, "origin")
    message = Map.get(params, "message")

    openai =
      System.fetch_env!("OPENAI_API_KEY")
      |> OpenaiEx.new()

    response = chat(openai, origin, message)

    Logger.info("Got response")

    # Wait a little before sending the response
    # to be more human
    :timer.sleep((1 + Enum.random(0..3)) * 1000)

    Logger.info("Sent response")

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, response)
  end
end
