defmodule ChipsWeb.PageController do
  use ChipsWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
