defmodule FishingJoy.Tester do
  require Logger

  alias FishingJoy.{Room, Player}

  @room_id "room001"
  @player_id_list ["1001", "1002", "1003", "1004"]

  def create_room(room_id \\ @room_id) do
    Room.create_room(room_id)
  end

  def close_room(room_id \\ @room_id) do
    Room.close_room(room_id)
  end

  def room_info(room_id \\ @room_id) do
    Room.info(room_id)
  end

  def start_four_player() do
    Enum.each(@player_id_list, fn id -> start_player(id) end)
  end

  def start_player(id) do
    Player.kickoff(id)
    user = %{id: id, money: 10000, diamond: 10}
    Player.info(id, user)
    Room.join(@room_id, id, user)
  end

  # 初始化，创建房间、玩家、加入房间等
  def create_room_user_join() do
    create_room()
    room_info()
    start_four_player()
    room_info()
  end

  # 启动游戏
  def start_game() do
    create_room_user_join()
  end
end


#    FishingJoy.Tester.create_room_user_join
#    FishingJoy.Tester.start_game