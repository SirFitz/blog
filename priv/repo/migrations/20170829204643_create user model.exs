defmodule :"Elixir.Blog.Repo.Migrations.Create user model" do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :lastname, :string
      add :firstname, :text
      add :password,  :string
      add :bio, :text
      add :gender, :text
      add :dob, :date
      add :email, :string
      add :phone, :string
      add :address, :string
      add :meta1, :string
      add :meta2, :string
      add :zid, :string
      add :photo, :string
      add :username, :string
      add :details, :map
      add :name, :string

      timestamps()
    end
  end
end
