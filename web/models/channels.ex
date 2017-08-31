defmodule Blog.Channel do
  use Blog.Web, :model

  schema "channels" do
    field :name, :string
    field :creator_id, :integer
    field :amount, :integer
    field :category, :string
    field :summary, :string
    field :type, :string
    field :status, :string
    field :meta1, :string
    field :meta2, :string

    timestamps()
  end
  @required_fields [:name]
  @optional_fields [:creator_id,:type,  :meta1, :meta2, :amount, :summary, :status]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(channels, params \\ %{}) do
   channels
   |> cast(params, Enum.concat(@required_fields, @optional_fields))
   |> validate_required(@required_fields)
 end
end

alias Blog.Channel
