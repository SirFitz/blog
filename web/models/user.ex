defmodule Blog.User do
  use Blog.Web, :model

  schema "users" do
    field :username, :string
    field :name, :string
    field :email, :string
    field :password, :string
    field :phone, :string
    field :address, :string
    field :zid, :string
    field :details, :map
    field :meta1, :string
    field :meta2, :string
    has_many :comments, Blog.Comment

    timestamps()
  end
  @required_fields [:username, :email, :zid, :password]
  @optional_fields [:phone, :meta1, :meta2, :details, :address, :name]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(user, params \\ %{}) do
   user
   |> cast(params, Enum.concat(@required_fields, @optional_fields))
   |> validate_required(@required_fields)
 end
end

alias Blog.User
