defmodule Blog.Repo.Migrations.AddFieldsToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :author, :string
      add :category, :integer
      add :preview, :string
      add :word_count, :integer
      add :publish_date, :date
      add :end_date, :date
      add :tags, :string
    end
    
  end
end
