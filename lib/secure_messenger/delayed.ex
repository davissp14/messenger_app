defmodule SecureMessenger.Delayed do
  use GenServer
  import Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :delayed)
  end

  def init(state) do
    {:ok, []}
  end

  def schedule_removal(target) do
    GenServer.cast(:delayed, {:schedule_removal, target})
  end

  def handle_cast({:schedule_removal, target}, state) do
    # SecureMessenger.Endpoint.broadcast("messages:test", "destroy_message", %{message_id: state})
    Process.send_after(:delayed, :remove_message, 1000 * 10)
    {:noreply, [target | state]}
  end

  # def schedule_it(state) do
  #   Logger.debug "Scheduling removal for: " <> inspect state
  #
  #   {:noreply, state}
  # end

  def handle_info(:remove_message, state) do
    Logger.debug inspect state
    target_id = List.last(state)
    adjusted_state = List.delete_at(state, -1)
    Logger.debug "Targeting " <> inspect target_id
    SecureMessenger.Endpoint.broadcast("messages:test", "destroy_message", %{message_id: target_id})

    {:noreply, adjusted_state}
  end

end
