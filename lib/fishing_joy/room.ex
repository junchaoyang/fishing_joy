defmodule FishingJoy.Room do
  use GenServer

  require Logger
  alias FishingJoy.{Tools, Player}

  # 一个人就可以玩了，最多四个人
  @lower_limit 1
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

  def shuffle(id) do
    call(id, :shuffle)
  end

  def notify_user_identify(player) do
    [banker, blind_big, blind_small | player_ids] = Map.keys(player)
    Player.notify_identity(banker, "banker")
    Player.notify_identity(blind_big, "blind_big")
    Player.notify_identity(blind_small, "blind_small")
    Enum.each(player_ids, fn id -> Player.notify_identity(id, "normal") end )
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
    state = %{id: id, lower_limit: @lower_limit, player: %{}, 
              player_count: 0, card_list: :lists.seq(1, 52)}
    {:ok, state}
  end

  @impl true
  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:join, uid, uinfo}, _from, state) do
    player = Map.put(state.player, uid, uinfo)
    player_count = state.player_count + 1
    {:reply, :ok, %{state | player: player, player_count: player_count}}
  end

  def handle_call(:shuffle, _from, state) do
    # 通知玩家此局的身份
    notify_user_identify(state.player)
    # 洗牌
    card_list = Enum.shuffle(state.card_list)
    # todo 切牌
    Logger.error("shuffle card_list: #{inspect(card_list)}")
    Logger.error("card_list format: #{inspect(Tools.format_cards(card_list))}")

    {:reply, :ok, %{state | card_list: card_list}}
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
