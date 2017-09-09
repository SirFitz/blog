defmodule :"Elixir.Blog.Repo.Migrations.Add channelId to posts" do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :channel_id, :integer
    end
  end
end
