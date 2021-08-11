defmodule FishingJoy.ApiClassics do
	alias FishingJoy.Struct.User

  def login(username, password) do
  	if username == "abc" and password == "123" do
  		# todo, get data form databases
  		%User{}
  	else
  		{:error, :not_fuond}
  	end
  	
  end

  def room_level() do
  	[%{
  			id: 1,
  	  	name: "珊瑚浅滩",
  	  	multiple_start: 1,
  	  	multiple_end: 500,
  		},
  		%{
  			id: 2,
  	  	name: "海底集市",
  	  	multiple_start: 50,
  	  	multiple_end: 800,
  		},
  		%{
  			id: 3,
  	  	name: "深海火山",
  	  	multiple_start: 100,
  	  	multiple_end: 1000,
  		},
  		%{
  			id: 4,
  	  	name: "机械深渊",
  	  	multiple_start: 200,
  	  	multiple_end: 4000,
  		},
  		%{
  			id: 5,
  	  	name: "无尽宇宙",
  	  	multiple_start: 500,
  	  	multiple_end: 4000,
  		}
  	]
  end
end