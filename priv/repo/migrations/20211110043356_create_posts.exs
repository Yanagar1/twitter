defmodule Twitter.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :text
      add :user_id, references(:users, on_delete: :delete), null: false

      timestamps()
    end

    create index(:posts, [:user_id])
  end
end
