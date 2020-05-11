defmodule BlogApp.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :content, :string
      add :likes, :integer
      add :push_id, :integer
      add :created_at, :utc_datetime_usec
      add :updated_at, :utc_datetime_usec
      add :created_at_server, :utc_datetime_usec
      add :updated_at_server, :utc_datetime_usec
      add :deleted_at_server, :utc_datetime_usec
      add :version, :bigint, default: fragment("nextval('version_seq')")
      add :version_created, :bigint, default: fragment("nextval('version_seq')")
    end

  end
end
