defmodule FishingJoyWeb.PageController do
  use FishingJoyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
