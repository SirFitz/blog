defmodule :"Elixir.Blog.Repo.Migrations.Add fields to users for compatibility with jodi's user schema" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
    end
  end
end
