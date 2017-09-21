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


  scope "/users", Blog do
    pipe_through :browser # Use the default browser stack
    get "/profile/:zid", UserController, :profile
    get "/profile/edit/:zid", UserController, :edit

  end
  scope "/channels", Blog do
    pipe_through :browser # Use the default browser stack

    get "/create", ChannelController, :create_view
    post "/create", ChannelController, :create
    post "/create/posts/:channel_id", ChannelController, :create_post
    get "/postform/:channel_id", ChannelController, :form
    get "/view/members/:channel_id", ChannelController, :view_members
    get "/channels/members/:channel_id/:member_id", ChannelController, :delete_members
    get "/view", ChannelController, :view
    get "/search", ChannelController, :search
    get "/join/:channel_id", ChannelController, :join
    get "/copy", ChannelController, :copy

    get "/notify", ChannelController, :notify

    get "/edit/:id", ChannelController, :edit
    post "/update/:id", ChannelController, :update
    get "/leave/:channel_id/:user_id", ChannelController, :leave
    get "/delete/:id", ChannelController, :delete
    get "/:id" , ChannelController, :index
  end



  scope "/", Blog do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/signup", AuthController, :signup
    get "/login", AuthController, :login
    post "/signin", AuthController, :signin
    post "/user/create", AuthController, :create_user
    post "/posts/new", PostController, :create
    post "/posts/:id", PostController, :update
    post "/posts", PostController, :index
    resources "/posts/", PostController do
      resources "/comments", CommentController, only: [:create]
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Blog do
  #   pipe_through :api
  # end
end
