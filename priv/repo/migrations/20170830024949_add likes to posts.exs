defmodule :"Elixir.Blog.Repo.Migrations.Add likes to posts" do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :likes, :integer
    end

  end
end
