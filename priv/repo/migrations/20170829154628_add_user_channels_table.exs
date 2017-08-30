defmodule Blog.Repo.Migrations.AddUserChannelsTable do
  use Ecto.Migration
  use Timex.Ecto.Timestamps

  def change do
    create table(:user_channels) do
      add :user_id, :integer
      add :channel_id, :integer
      add :date_joined, :naive_datetime
      add :status, :string
      add :meta1, :string

      timestamps()
    end
  end
end
