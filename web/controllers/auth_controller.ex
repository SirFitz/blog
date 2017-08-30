defmodule Blog.AuthController do
  @moduledoc """
  AuthenticationController implements the  authentication workflow for
  performing the users authentication
  """
  use Blog.Web, :controller
  import Ecto.Query
  alias Blog.User

  def signup(conn, params) do
    changeset = User.changeset(%User{})
    render(conn, "signup.html", changeset: changeset,params: params)

  end

  def create_user(conn, user_params) do

    required_params = %{zid: Ecto.UUID.generate,   username: String.strip(user_params["username"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" "), email: String.downcase(user_params["email"]), password: user_params["password"], name: IO.inspect String.strip(user_params["name"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")}
    changeset = User.changeset(%User{}, required_params)
    case Repo.insert(changeset) do
     {:ok, user} ->
       conn
       |> put_flash(:info, "User created successfully.")
       |> redirect(to: "/")
       Webapp.Mailer.send_welcome_email(user.email)
     {:error, changeset} ->
       IO.inspect changeset
       render(conn, "signup.html", changeset: changeset, params: user_params)
     end
  end


  def login(conn, _params) do
      changeset = User.changeset(%User{})
      render conn, "login.html", changeset: changeset
  end

  def signin(conn,  user_params) do
    email = String.strip(String.downcase(user_params["email"]))
    password = String.strip(user_params["password"])
    time_in_secs_from_now = 86400 * 90
    user = Repo.get_by(User, email: email, password: password )

    cond do
      user ->
          conn
           |> delete_resp_cookie("bloguser")
           |> put_resp_cookie("bloguser", user.zid, max_age: time_in_secs_from_now)
           |> put_flash(:info, "Logged in")
           |> redirect(to: "/")


      is_nil(user)->
          conn
          |> put_flash(:error,"No user found")
          |> render("login.html")
    end
end

end
