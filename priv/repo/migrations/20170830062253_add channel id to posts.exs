defmodule :"Elixir.Blog.Repo.Migrations.Add channel id to posts" do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :channel_id, :integer
    end
  end
end
