defmodule Blog.PostController do
  use Blog.Web, :controller

  alias Blog.{Post, Comment}

  def index(conn, params) do

    IO.inspect params
    posts = from p in Blog.Post,
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

    {posts, kerosene} =
      posts
      |> where([p], is_nil(p.title) == false )
      |> Repo.paginate()

    render(conn, "index.html", posts: posts, kerosene: kerosene)
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do

    word_count =
      Map.get(post_params, "body")
      |> String.trim()
      |> String.graphemes()
      |> Enum.dedup_by(fn(x) -> x end)
      |> Enum.count(fn(x) -> x == " " end)

    Map.put(post_params, "word_count", word_count)

    changeset = Post.changeset(%Post{}, post_params)

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

    IO.inspect post_params

    space_count =
      Map.get(post_params, "body")
      |> String.trim()
      |> String.graphemes()
      |> Enum.dedup_by(fn(x) -> x end)
      |> Enum.count(fn(x) -> x == " " end)

    word_count = space_count+1

    post_params = Map.put(post_params, "word_count", word_count)
    IO.inspect post_params

    post = Repo.get!(Post, id)

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
