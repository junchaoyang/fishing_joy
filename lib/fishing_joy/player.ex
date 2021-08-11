defmodule FishingJoy.Player do
  use GenServer
  alias FishingJoy.Tools
  require Logger


  def info(id) do
    call(id, :info)
  end

  def info(id, params) do
    call(id, {:info, params})
  end

  def fire(id, params) do
    call(id, {:fire, params})
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
    {:ok, %{id: id}}
  end

  @impl true
  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end
  def handle_call({:info, params}, _from, state) do
    {:reply, :ok, params}
  end

  def handle_call({:fire, params}, _from, state) do
    Logger.error("fire:#{inspect(params)}")
    {:reply, :ok, state}
  end
  
  @impl true
  def handle_cast(:reload, state) do
    {:noreply, state}
  end

  def handle_cast({:stop, reason}, state) do
    {:stop, reason, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.error("Player msg: #{msg}")
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.error("reason:#{inspect(reason)}, state:#{inspect(state)}")
    :ok
  end

  defp cast(id, params) do
    case Registry.lookup(Registry.Player, id) do
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
    case Registry.lookup(Registry.Player, id) do
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
