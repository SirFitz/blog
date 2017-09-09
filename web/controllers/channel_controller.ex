defmodule Blog.ChannelController do
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

  def index(conn, params) do
    channel = Repo.get_by(Channel,  id: params["id"] )
    current_user = Repo.get_by(User, zid: conn.cookies["bloguser"])
    posts_list = Repo.all(from p in Post, where: p.channel_id == ^channel.id)
    posts =
      if Enum.count(posts_list) > 0 do
        Repo.all(from p in Post, where: p.channel_id == ^channel.id)
      else
        nil
      end
    IO.inspect posts
    render(conn, "channel.html", channel: channel, posts: posts, user: current_user)
  end

  def form(conn, params) do
    channel = Repo.get_by(Channel,  id: params["channel_id"] )
    render(conn, "channel_post.html", channel: channel)
  end

  def create_view(conn, params) do
    changeset = Channel.changeset(%Channel{})
    render(conn, "create.html", changeset: changeset,params: params)

  end
  def create(conn, params) do
    IO.inspect params
    current_user = Repo.get_by(User, zid: conn.cookies["bloguser"])
    name = "#" <> String.strip(params["name"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")
    required_params = %{creator_id: current_user.id, summary: params["summary"], type: params["type"],   name: name}
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
    current_user = Repo.get_by(User, zid: conn.cookies["bloguser"])

    query = from c in Channel, join: u in UserChannel, where: c.id == u.channel_id  and  is_nil(c.type),  distinct: c.id
    channels = Repo.all(query)
    # IO.inspect subscribers
    render conn, "viewlist.html",  channels: channels, user: current_user
  end

  def search(conn, params) do
    current_user = Repo.get_by(User, zid: conn.cookies["bloguser"])

    cname = String.strip(params["name"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")
    query = from c in Channel, join: u in UserChannel, where:  fragment("? ~* ?", c.name, ^cname) and c.id == u.channel_id and  is_nil(c.type), distinct: c.id
    channels =  Repo.all(query)
    render conn, "viewlist.html",  channels: channels, user: current_user

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

    channel = Repo.get_by(Channel,  id: params["channel_id"])
    current_user = Repo.get_by(User, zid: conn.cookies["bloguser"])
    unless channel.type == "private" do
      changeset = UserChannel.changeset(%UserChannel{}, %{channel_id: channel.id, user_id: current_user.id, status: "active"})
      Blog.Repo.insert(changeset)
      conn
      |> put_flash(:info, "Joined successfully.")
      |> redirect(to: "/channels/" <> params["channel_id"])


    end
  end

  def like(conn, params) do
    user = Repo.get_by(User, id: params["person_id"])
    likes = user.likes + 1
    changeset = User.changeset(user, %{likes: likes})
    Repo.update(changeset)
  end
  def unlike(conn, params) do
    user = Repo.get_by(User, id: params["person_id"])
    likes = user.likes - 1
    changeset = User.changeset(user, %{likes: likes})
    Repo.update(changeset)
  end

  def leave(conn, params) do

    case  Repo.get_by(UserChannel,  channel_id: params["channel_id"], user_id: params["user_id"]) do
      nil -> "You cannot delete the channel"
      channel ->

       case Repo.delete(channel) do
        {:ok, struct}       -> IO.inspect struct
        {:error, changeset} -> IO.inspect changeset
       end
       conn
       |> redirect(to: "/channels/view")
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

  def create_post(conn, params) do
    user = Repo.get_by(User, zid: conn.cookies["bloguser"])
    post_params = %{"body" => params["body"], "channel_id" => params["channel_id"],  "tags" => params["tags"], "title" => params["title"]}
    space_count =
      params["body"]
      |> String.trim()
      |> String.graphemes()
      |> Enum.dedup_by(fn(x) -> x end)
      |> Enum.count(fn(x) -> x == " " end)

    word_count = space_count+1
    post_params = Map.put(post_params, "word_count", word_count)
    post_params = Map.put(post_params, "author", user.name)

    IO.inspect post_params
    IO.inspect changeset = Post.changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} -> IO.puts "Oops"
        render(conn, "channel_post.html", changeset: changeset)
    end
  end

  def invite(conn, params) do
    channel = Repo.get_by(Channel, id: params["channel_id"])
    render(conn, "invite.html", channel: channel)
  end

  def send_invite(conn, params) do
    #
  end



  def notify(conn, params) do
    unseen_ids = Repo.all(from p in Post, join: c in Channel, where: c.id == p.channel_id and fragment("? > now() - interval '1 second'", p.updated_at),  limit: 5)
    #IO.inspect unseen_ids.inserted_at
    for i <- unseen_ids do
      IO.inspect i.inserted_at
    end
    unseen = 0
    IO.inspect unseen
    notification_msg = "   <li>
        <p>NOTIFICATIONS <span class='new badge'>4</span></p>
      </li>
      <li class='divider'></li>
      <li>
        <a href=''><i class='mdi-action-add-shopping-cart'></i> A new order has been placed!</a>
        <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>2 hours ago</time>
      </li>

      <li>
        <a href=''><i class='mdi-action-settings'></i> Settings updated</a>
        <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>4 days ago</time>
      </li>"
      data =  %{"notification"   => "<li>
      <p><b>Notifications</b> <span class='new badge'>4</span></p>
        </li>
        <li>
          <a href=''><i class='mdi-action-add-shopping-cart'></i>Chanel 1- This is life</a>
          <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>2 hours ago</time>
        </li>
        <li>
          <a href=''><i class='mdi-action-add-shopping-cart'></i> A new order has been placed!</a>
          <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>2 hours ago</time>
        </li>
        <li>
          <a href=''><i class='mdi-action-add-shopping-cart'></i> A new order has been placed!</a>
          <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>2 hours ago</time>
        </li>" ,
        "unseen_notification" => unseen }
       json(conn, data)
  end

  def view_members(conn, params) do
    channel = Repo.get_by(Channel, id: params["channel_id"])

    members = Repo.all( from user in User, join: u in UserChannel, where: user.id == u.user_id and u.channel_id == ^params["channel_id"])
    render(conn, "view_members.html", members: members, channel: channel)
  end

  def delete_members(conn, params) do
      # if you are the creator of the group you can delete anyone
      channel = Repo.get_by(Channel, id: params["channel_id"])
      if conn.asigns["current_user"].id  == channel.creator_id do
        case  Repo.get_by(UserChannel,  channel_id: params["channel_id"], user_id: params["member_id"]) do
          nil -> "You cannot delete the member"
          conn
          |> put_flash(:info, "You Cannot delete this member.")
          |> redirect(to: "/")
          userchannel ->

           case Repo.delete(userchannel) do
            {:ok, struct}       -> IO.inspect struct
            {:error, changeset} -> IO.inspect changeset
           end
        end
      end
  end

  def share(conn,params) do

  end

  def repost(conn,params) do

  end

  def copy(conn, params) do
      # if you are the creator of the group you can delete anyone
      channel = params["channel"]
      id = params["id"]
      post =
         Repo.get!(Blog.Post, id)
        |> Map.put(:id ,:rand.uniform(9999))
        |> Map.put(:channel_id, channel)
        |> Repo.preload(:comments)
      map = %{"channel_id" => channel}

      changeset = Post.changeset(post, map)

      case Repo.insert(changeset) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post created successfully.")
          |> redirect(to: "/channels/view")
        {:error, changeset} ->
        conn |>  redirect(to: "/posts")
      end
  end

end
