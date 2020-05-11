defmodule BlogApp.Sync do
  alias BlogApp.{Repo, Blog}

  def push(changes, last_pulled_version) do
    push_id = Enum.random(1..1_000_000_000)

    Ecto.Multi.new()
    |> Blog.record_posts(changes["posts"], last_pulled_version, push_id)
    |> Repo.transaction()

    pull(last_pulled_version, push_id)
  end

  def pull(last_pulled_version, push_id \\ nil) do
    %{latest_version: latest_version_posts, changes: posts_changes} =
      Blog.list_posts_changes(last_pulled_version, push_id)

    latest_version =
      [last_pulled_version, latest_version_posts]
      |> Enum.max()

    %{
      "latestVersion" => latest_version,
      "changes" => %{
        "posts" => posts_changes
      }
    }
  end
end
