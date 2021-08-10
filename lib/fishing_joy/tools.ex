defmodule FishingJoy.Tools do

  def format_cards(card_list) do
    format_cards(card_list, [])
  end

  defp format_cards([], res) do
    Enum.reverse(res)
  end
  defp format_cards([card | card_list], res) do
    card_num = div(card, 4) + 1
    card_type = card_type(rem(card, 4) )
    item = "#{card_type}#{card_num}"
    format_cards(card_list, [ item | res])
  end

  def card_type(1) do
    "♦"
  end
  def card_type(2) do
    "♣"
  end
  def card_type(3) do
    "♥"
  end
  def card_type(0) do
    "♠"
  end

  def random(max_limit) do
  	:rand.uniform(max_limit)
  end

  def random_blind_bet(money) do
  	 random(div(money, 100)) 
  end

  def user_identity(1) do
  	"庄"
  end
  def user_identity(2) do
  	"大盲"
  end
  def user_identity(3) do
  	"小盲"
  end
  def user_identity(4) do
  	"普通玩家"
  end
	
end