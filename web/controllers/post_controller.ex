defmodule Blog.PostController do
  use Blog.Web, :controller

  alias Blog.{Post, Comment, User}

  plug :cookie

  def cookie(conn, params) do
    cookie = conn.cookies["user"]
    case cookie != nil do
      true ->
      assign(conn, :user, cookie)
      false ->
      cookie = Ecto.UUID.generate
      conn
        |> put_resp_cookie("user", cookie, path: "/", max_age: (86400 * 3600))
      assign(conn, :user, cookie)
    end
  end

  def index(conn, params) do

    IO.inspect params
    posts = from p in Blog.Post, where: is_nil(p.channel_id),
            select: p

    posts =
      if params["title_search"] != "" and params["title_search"] != nil do
        posts
          |> where([p], fragment("? ~* ?", p.title, ^params["title_search"]))
      else
        posts
      end

    IO.inspect posts
    posts =
      if params["content_search"] != "" and params["content_search"] != nil do
        posts
          |> where([p], fragment("? ~* ?", p.body, ^params["content_search"]))
      else
        posts
      end

    posts =
      if params["author_search"] != "" and params["author_search"] != nil do
        posts
          |> where([p], fragment("? ~* ?", p.author, ^params["author_search"]))
      else
        posts
      end

    posts =
      if params["tags_search"] != "" and params["tags_search"] != nil do
        posts
          |> where([p], fragment("? ~* ?", p.tags, ^params["tags_search"]))
      else
        posts
      end

      posts =
        if params["date_sort"] == "asc" do
           posts
             |> order_by([p], asc: p.inserted_at)
        else
          posts
        end

    posts =
      if params["likes_search"] != "" and params["likes_search"] != nil do
        likes = String.split(params["likes_search"], "-")
      IO.inspect  ulikes = Enum.at(likes, 0)
      IO.inspect  olikes = Enum.at(likes, 1)
        posts
          |> where([p], p.likes > ^ulikes and p.likes < ^olikes)
      else
        posts
      end

    posts =
        if params["ratings_sort"] == "desc" do
         posts
          |> order_by([p], asc: p.likes)
        else
          posts
        end

    posts =
          if params["ratings_sort"] == "asc" do
            posts
            |> order_by([p], desc: p.likes)
      else
        posts
      end

    posts =
      if params["comments_search"] != "" and params["comments_search"] != nil do

        comments =
              Blog.Comment
                |> where([c], fragment("? ~* ?", c.body, ^params["comments_search"]))
                |> Blog.Repo.all


        post_ids = Enum.map(comments, fn(x) -> Map.get(x, :post_id) end)
        posts
          |> where([p], p.id in ^post_ids)
      else
        posts
      end

    {posts, kerosene} =
      posts
      |> where([p], is_nil(p.title) == false )
      |> Repo.paginate(params)


    changeset = Post.changeset(%Post{})


    render(conn, "index.html", posts: posts, kerosene: kerosene, changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do

    space_count =
      Map.get(post_params, "body")
      |> String.trim()
      |> String.graphemes()
      |> Enum.dedup_by(fn(x) -> x end)
      |> Enum.count(fn(x) -> x == " " end)

    word_count = space_count+1

    post_params = Map.put(post_params, "word_count", word_count)
    IO.inspect post_params
    IO.inspect changeset = Post.changeset(%Post{}, post_params)
    case Repo.insert(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Post
		|> Repo.get!(id)
		|> Repo.preload(:comments)
    comment_changeset = Comment.changeset(%Comment{})
    render(conn, "show.html", post: post, comment_changeset: comment_changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    changeset = Post.changeset(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do

    if Map.get(post_params, "body") != nil do
      space_count =
        Map.get(post_params, "body")
        |> String.trim()
        |> String.graphemes()
        |> Enum.dedup_by(fn(x) -> x end)
        |> Enum.count(fn(x) -> x == " " end)

      word_count = space_count+1

      post_params = Map.put(post_params, "word_count", word_count)
    end

    post = Repo.get!(Post, id)



    if Map.get(post_params, "likes") != nil do
      if post.likes == nil do
        likes = 1
      else
        likes = post.likes + 1
      end
      post_params = Map.put(post_params, "likes", likes)
    end

    changeset = Post.changeset(post, post_params)
    IO.inspect changeset
    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end
end
