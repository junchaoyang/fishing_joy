defmodule FishingJoy.Player do
  use GenServer

  require Logger

  alias FishingJoy.Tools

  def info(id) do
    call(id, :info)
  end

  def notify_identity(id, identity) do
    cast(id, {:notify_identity, identity})
  end

  def kickoff(id) do
    DynamicSupervisor.start_child(PlayerSupervisor, {__MODULE__, id})
  end

  def via_tuple(name) do
    {:via, Registry, {Registry.Player, name}}
  end

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  @impl true
  def init(id) do
    {:ok, %{id: id, money: 20000, identity: ""}}
  end

  @impl true
  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end
  
  @impl true
  def handle_cast(:reload, state) do
    {:noreply, state}
  end

  def handle_cast({:stop, reason}, state) do
    {:stop, reason, state}
  end

  @impl true
  def handle_info(:notify_blind_bet, state) do
    # 通知小盲下注
    # todo
    # send msg to client 
    # client send blind_bet 
    
    blind_bet = Tools.random_blind_bet(state.money)
    {:noreply, state}
  end

  # 通知用户此局的身份
  def handle_info({:notify_identity, identity}, state) do
    Logger.warn("user:#{state.id},identity:#{inspect(identity)}")
    {:noreply, %{state | identity: identity}}
  end

  def terminate(reason, state) do
    Logger.error("reason:#{inspect(reason)}, state:#{inspect(state)}")
    :ok
  end

  defp cast(id, params) do
    case Registry.lookup(Registry.Room, id) do
      [{pid, _}] ->
        GenServer.cast(pid, params)

      [] ->
        case kickoff(id) do
          {:ok, pid} -> GenServer.cast(pid, params)
          _ -> :error
        end
    end
  end

  defp call(id, params) do
    case Registry.lookup(Registry.Room, id) do
      [{pid, _}] ->
        GenServer.call(pid, params)

      [] ->
        :noprocess
        case kickoff(id) do
          {:ok, pid} -> GenServer.call(pid, params)
          _ -> :error
        end
    end
  end
end
