defmodule Blog.PageController do
  use Blog.Web, :controller

  def index(conn, _params) do
    #render conn, "index.html"
    # conn |> redirect(to: "/login")
    conn |> redirect(to: "/posts")
  end
end
