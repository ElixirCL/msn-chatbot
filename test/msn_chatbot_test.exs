defmodule MsnChatbotTest do
  use ExUnit.Case
  doctest MsnChatbot

  test "greets the world" do
    assert MsnChatbot.hello() == :world
  end
end
