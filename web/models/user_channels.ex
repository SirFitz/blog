defmodule Blog.UserChannel do
  use Blog.Web, :model

  schema "user_channels" do
    field :user_id, :integer
    field :channel_id, :integer
    field :date_joined, :naive_datetime
    field :status, :string
    field :meta1, :string
    has_many :users, Blog.User
    has_many :channels, Blog.Channel

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, Map.keys(params))

  end
end

alias Blog.UserChannel
