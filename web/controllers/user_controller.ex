defmodule Blog.UserController do
  @moduledoc """
  AuthenticationController implements the  authentication workflow for
  performing the users authentication
  """
  use Blog.Web, :controller
  import Ecto.Query
  alias Blog.User
  alias Blog.Post
  alias Blog.Channel
  alias Blog.Repo
  alias Blog.UserChannel
  use Timex

  def profile(conn, params) do
    user = Repo.get_by(User, zid: params["zid"])
    IO.inspect user.id
    mychannels = Repo.all(from c in Channel, where: c.creator_id == ^user.id)
    IO.inspect mychannels
    joined_channels = Repo.all(from  c in Channel, join: u in UserChannel, where: c.id == u.channel_id and c.creator_id != u.user_id and u.user_id == ^user.id)
    render conn, "profile.html", user: user, mychannels: mychannels, joined_channels: joined_channels
  end

  def edit(conn, params) do
    user = Repo.get_by(User,  zid: params["zid"])
    render conn, "edit_profile.html", user: user
  end

end
