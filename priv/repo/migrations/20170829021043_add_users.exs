defmodule Blog.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :name, :string
      add :email, :string
      add :password, :string
      add :phone, :string
      add :address, :string
      add :zid, :string
      add :details, :map
      add :meta1, :string
      add :meta2, :string
      timestamps()
    end
  end
end
