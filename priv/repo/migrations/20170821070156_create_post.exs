defmodule Blog.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :text
      add :preview, :string
      add :word_count, :integer
      add :publish_date, :date
      add :end_date, :date
      add :tags, :string
      add :category, :integer
      add :author, :string
      add :channel_id, :integer

      timestamps()
    end
  end
end
