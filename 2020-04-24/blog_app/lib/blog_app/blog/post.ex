defmodule BlogApp.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: [:id, :title, :content, :likes]}
  schema "posts" do
    field :content, :string
    field :created_at, :utc_datetime_usec
    field :created_at_server, :utc_datetime_usec
    field :deleted_at_server, :utc_datetime_usec
    field :likes, :integer
    field :push_id, :integer
    field :title, :string
    field :updated_at, :utc_datetime_usec
    field :updated_at_server, :utc_datetime_usec
    field :version, :integer
    field :version_created, :integer
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :likes, :push_id, :created_at, :updated_at, :created_at_server, :updated_at_server, :deleted_at_server, :version, :version_created])
    |> validate_required([:title, :content, :likes, :push_id, :created_at, :updated_at, :created_at_server, :updated_at_server, :deleted_at_server, :version, :version_created])
  end
end
