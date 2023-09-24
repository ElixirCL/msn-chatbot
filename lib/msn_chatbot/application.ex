defmodule MsnChatbot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: MsnChatbot.Worker.start_link(arg)
      # {MsnChatbot.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: MsnChatbot, options: [port: 3000]},
      {MsnChatbot.Memory, %{}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MsnChatbot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
