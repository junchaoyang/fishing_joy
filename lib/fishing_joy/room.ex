defmodule FishingJoy.Room do
  use GenServer

  require Logger
  alias FishingJoy.{Tools, Player}

  # 房间至少一个人
  @lower_limit 1
  # 最多四个人
  @upper_limit 4
  

  def close_room(id) do
    cast(id, :close)
  end

  def create_room(id) do
    kickoff(id)
  end

  def info(id) do
    call(id, :info)
  end

  def join(id, uid, uinfo) do
    call(id, {:join, uid, uinfo})
  end

  def leave(id, uid, uinfo) do
    call(id, {:leave, uid})
  end

  def kickoff(id) do
    DynamicSupervisor.start_child(RoomSupervisor, {__MODULE__, id})
  end

  def via_tuple(name) do
    {:via, Registry, {Registry.Room, name}}
  end

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  @impl true
  def init(id) do
    state = %{id: id, 
              lower_limit: @lower_limit, 
              upper_limit: @upper_limit, 
              player: %{}, 
              player_count: 0
            }
    {:ok, state}
  end

  @impl true
  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end
  
  # 进入房间
  def handle_call({:join, uid, uinfo}, _from, state) 
             when state.player_count >= @upper_limit do
    {:reply, {:error, :full}, state}
  end
  def handle_call({:join, uid, uinfo}, _from, state) do
    player = Map.put(state.player, uid, uinfo)
    player_count = state.player_count + 1
    state = %{state | player: player, player_count: player_count}
    {:reply, {:ok, self()}, state}
  end

  # 离开房间
  def handle_call({:leave, uid}, _from, state) do
    player = state.player
    if Map.has_key?(player, uid) do
      player = Map.delete(player, uid)
      player_count = state.player_count - 1
      state = %{state | player: player, player_count: player_count}
      {:reply, :ok, state}  
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  def handle_cast(:reload, state) do
    {:noreply, state}
  end

  def handle_cast(:close, state) do
    {:stop, :close, state}
  end

  @impl true
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
