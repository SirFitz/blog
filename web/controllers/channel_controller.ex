defmodule Blog.ChannelController do
  @moduledoc """
  AuthenticationController implements the  authentication workflow for
  performing the users authentication
  """
  use Blog.Web, :controller
  import Ecto.Query
  alias Blog.User
  alias Blog.Channel
  alias Blog.Repo
  alias Blog.UserChannel
  use Timex

  def index(conn, params) do
    channel = Repo.get_by(Channel,  id: params["id"] )
    render(conn, "channel.html", channel: channel)
  end

  def create_view(conn, params) do
    changeset = Channel.changeset(%Channel{})
    render(conn, "create.html", changeset: changeset,params: params)

  end
  def create(conn, params) do
    IO.inspect params
    current_user = conn.cookies["bloguser"]
    required_params = %{creator_id: 1, summary: params["summary"], type: "private",   name: String.strip(params["name"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")}
    changeset = Channel.changeset(%Channel{}, required_params)
    case Blog.Repo.insert(changeset) do
     {:ok, channel} ->
       changeset = UserChannel.changeset(%UserChannel{}, %{channel_id: channel.id, user_id: channel.creator_id, status: "active"})
       Blog.Repo.insert(changeset)
       conn
       |> put_flash(:info, "Channel created successfully.")
       |> redirect(to: "/channels/view")

     {:error, changeset} ->
       IO.inspect changeset
       render(conn, "create.html", changeset: changeset)
     end
  end

  def view(conn, params) do
    # get all the channels that this user is apart of-
    current_user = conn.cookies["bloguser"]

    query = from c in Channel, join: u in UserChannel, where: c.id == u.channel_id and u.user_id == 1
    channels = Repo.all(query)
    # IO.inspect subscribers
    render conn, "viewlist.html",  channels: channels
  end

  def search(conn, params) do

    cname = String.strip(params["name"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")
    query = from c in Channel, join: u in UserChannel, where:  fragment("? ~* ?", c.name, ^cname) and c.id == u.channel_id and u.user_id == 1
    channels =  Repo.all(query)
    render conn, "viewlist.html",  channels: channels

  end

  def edit(conn, params) do
    channel = Repo.get_by(Channel,  id: params["id"])
    render conn, "edit.html", channel: channel
  end
  
  def update(conn,params) do
    channel = Repo.get!(Channel, params["id"])
    #if params["type"] == "" do type = channel.type else type = params["type"] end
    if params["name"] == "" do name = channel.name else name = params["name"] end
    if params["summary"] == "" do phone = channel.summary else summary = params["summary"] end
    changeset = Channel.changeset(channel, %{type: "public",name: name , summary: summary})
    case Repo.update(changeset) do
      {:ok, _channel} ->
        conn
        |> put_flash(:info, "Channel updated successfully.")
        |> redirect(to: "/channels/view")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Oops error!")
        |> redirect(to: "/channels/edit")
    end
  end

  def join(conn, params) do
    #or request to join
    # first check that the channel is public
    channel = Repo.get_by(Channel,  id: params["id"])
    current_user = conn.cookies["bloguser"]
    unless channel.type == "private" do
      changeset = UserChannel.changeset(%UserChannel{}, %{channel_id: channel.id, user_id: 1, status: "active"})
      Blog.Repo.insert(changeset)

    end
  end


  def leave(conn, params) do
    case  Repo.get_by(UserChannel,  channel_id: params["channel_id"], user_id: params["user_id"]) do
      nil -> "You cannot delete the channel"
      channel ->

       case Data.Repo.delete(channel) do
        {:ok, struct}       -> IO.inspect struct
        {:error, changeset} -> IO.inspect changeset
       end
    end
  end

  def delete(conn, params) do
    current_user = conn.cookies["bloguser"]
    channel =  Repo.get_by(Channel,  id: params["id"], creator_id: 1)
    case  channel do
      nil -> "You cannot delete the channel"
      channel ->

       case Repo.delete(channel) do
        {:ok, struct}       -> IO.inspect struct
        {:error, changeset} -> IO.inspect changeset

       end
       conn
       |> put_flash(:info, "Channel deleted successfully.")
       |> redirect(to: "/channels/view")

    end
  end

  def invite(conn, params) do

  end

  def post(conn, params) do

  end

  def notify(conn, params) do

  end
  def share(conn,params) do

  end

  def repost(conn,params) do

  end

  def view_members(conn, params) do

  end

  def delete_members(conn, params) do

  end
end
