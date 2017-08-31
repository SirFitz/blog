defmodule Blog.Router do
  use Blog.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/channels", Blog do
    pipe_through :browser # Use the default browser stack

    get "/create", ChannelController, :create_view
    post "/create", ChannelController, :create
    get "/postform", ChannelController, :form
    get "/view", ChannelController, :view
    get "/search", ChannelController, :search
    get "/edit/:id", ChannelController, :edit
    post "/update/:id", ChannelController, :update
    get "/leave/:channel_id/:user_id", ChannelController, :leave
    get "/delete/:id", ChannelController, :delete
    get "/:id" , ChannelController, :index
  end

  scope "/", Blog do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
<<<<<<< HEAD
    post "/posts/new", PostController, :create
    post "/posts", PostController, :index
    resources "/posts/", PostController do
    	resources "/comments", CommentController, only: [:create]
=======
    get "/signup", AuthController, :signup
    get "/login", AuthController, :login
    post "/signin", AuthController, :signin
    post "/user/create", AuthController, :create_user
    post "/posts", PostController, :index
    resources "/posts/", PostController do
      resources "/comments", CommentController, only: [:create]
>>>>>>> master
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Blog do
  #   pipe_through :api
  # end
end
