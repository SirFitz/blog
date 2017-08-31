defmodule Blog.Post do
  use Blog.Web, :model

  schema "posts" do
    field :title, :string
    field :body, :string
    field :author, :string
    field :category, :integer
    field :preview, :string
    field :word_count, :integer
    field :publish_date, :date
    field :end_date, :date
    field :channel_id, :integer
    field :tags, :string
    field :likes, :integer
    has_many :comments, Blog.Comment

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, Map.keys(params))
    |> validate_required([:title, :body])
  end
end

alias Blog.Post
