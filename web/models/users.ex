defmodule Blog.User do
    use Blog.Web, :model

    schema "users" do
      field :lastname, :string
      field :firstname, :string
      field :password,  :string
      field :bio, :string
      field :gender, :string
      field :dob, :date
      field :email, :string
      field :phone, :string
      field :address, :string
      field :meta1, :string
      field :meta2, :string
      field :uid, :string
      field :photo, :string

      timestamps()
    end

    @doc """
    Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, Map.keys(params))
      |> validate_required(:uid)
    end
  end

  alias Blog.User
