defmodule BlogAppWeb.PageController do
  use BlogAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
