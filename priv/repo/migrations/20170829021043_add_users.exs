defmodule Blog.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
      add :zid, :string
      add :details, :map
      
    end
  end
end
