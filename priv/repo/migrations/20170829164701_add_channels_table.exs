defmodule Blog.Repo.Migrations.AddChannelsTable do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :creator_id, :integer
      add :amount, :integer
      add :category, :string
      add :summary, :string
      add :type, :string
      add :status, :string
      add :meta1, :string
      add :meta2, :string


      timestamps()
    end
  end
end
