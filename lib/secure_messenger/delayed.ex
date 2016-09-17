defmodule SecureMessenger.Delayed do
  use GenServer
  import Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :delayed)
  end

  def init(state) do
    {:ok, []}
  end

  def schedule_removal(channel, message_id) do
    GenServer.cast(:delayed, {:schedule_removal, channel, message_id})
  end

  def handle_cast({:schedule_removal, channel, message_id}, state) do
    Process.send_after(:delayed, :remove_message, 1000 * 10)
    target = "#{channel}:#{message_id}"
    {:noreply, [target | state]}
  end

  def handle_info(:remove_message, state) do
    target = String.split(List.last(state), ":")
    adjusted_state = List.delete_at(state, -1)
    channel = "channels:" <> List.first(target)
    message_id = List.last(target)
    SecureMessenger.Endpoint.broadcast(channel, "destroy_message", %{message_id: message_id})

    {:noreply, adjusted_state}
  end

end
