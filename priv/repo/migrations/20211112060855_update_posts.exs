defmodule Twitter.Repo.Migrations.UpdatePosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :likes_count, :integer
      add :shares_count, :integer
    end
  end
end
