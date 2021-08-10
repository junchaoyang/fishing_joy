defmodule FishingJoy.Tester do
  require Logger

  alias FishingJoy.{Room, Player}

  @room_id "room001"
  @player_id_list ["1001", "1002", "1003", "1004", "1005"]

  def create_room() do
    Room.create_room(@room_id)
  end

  def close_room() do
    Room.close_room(@room_id)
  end

  def room_info do
    Room.info(@room_id)
  end

  def start_five_player() do
    Enum.each(@player_id_list, fn id -> start_player(id) end)
  end

  def start_player(id) do
    Player.kickoff(id)
    Room.join(@room_id, id, %{money: 10000})
  end

  # 初始化，创建房间、玩家、加入房间等
  def create_room_user_join() do
    create_room()
    room_info()
    start_five_player()
    room_info()
  end

  def shuffle() do
    Room.shuffle(@room_id)
  end

  # 启动游戏
  def start_game() do
    # 第一个进房间的为庄家
    # 1.洗牌并切牌。
    shuffle()
    # 2.本次轮到担任盲注的牌手下盲注。
    

  end
end


#    FishingJoy.Tester.create_room_user_join
#    FishingJoy.Tester.start_game