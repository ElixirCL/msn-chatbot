defmodule MsnChatbot.Memory do
  use GenServer

  @me __MODULE__

  def start_link(state \\ %{}) do
    GenServer.start_link(@me, state, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def stop() do
    GenServer.stop(@me)
  end

  def set(key, value) do
    GenServer.cast(@me, {:set, key, value})
  end

  def get(key) do
    GenServer.call(@me, {:get, key})
  end

  def handle_cast({:set, key, value}, state) do
    new_value =
      case Map.get(state, key) do
        nil -> [value]
        prev -> prev ++ [value]
      end

    {:noreply, Map.put(state, key, new_value)}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, state[key], state}
  end
end
