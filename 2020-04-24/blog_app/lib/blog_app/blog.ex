defmodule BlogApp.Blog do
  import Ecto.Query
  alias Ecto.Multi
  alias BlogApp.Repo
  alias BlogApp.Blog.Post

  def record_posts(%Multi{} = multi, post_changes, last_pulled_version, push_id) do
    multi
    |> Multi.run(:check_conflict_posts, fn _, _changes ->
      case check_conflict_version_posts(post_changes, last_pulled_version) do
        :no_conflict -> {:ok, :no_conflict}
        :conflict -> {:error, :conflict}
      end
    end)
    |> record_created_posts(post_changes["created"] |> set_push_id(push_id))
    |> record_updated_posts(post_changes["updated"] |> set_push_id(push_id))
    |> record_deleted_posts(post_changes["deleted"], push_id)
  end

  def check_conflict_version_posts(post_changes, last_pulled_version) do
    ids =
      Enum.concat(post_changes["created"], post_changes["updated"])
      |> Enum.map(fn post -> post["id"] end)
      |> Enum.concat(post_changes["deleted"])

    count =
      Post
      |> select([p], count(p.version))
      |> where([p], p.id in ^ids)
      |> where([p], p.version > ^last_pulled_version or p.version_created > ^last_pulled_version)
      |> Repo.one()

    case count do
      0 -> :no_conflict
      _ -> :conflict
    end
  end

  def record_created_posts(%Multi{} = multi, created_changes),
    do: upsert_posts(multi, :create_posts, created_changes)

  def record_updated_posts(%Multi{} = multi, updated_changes),
    do: upsert_posts(multi, :update_posts, updated_changes)

  def upsert_posts(%Multi{} = multi, _name, attrs) when is_nil(attrs),
    do: multi

  def upsert_posts(%Multi{} = multi, name, attrs) do
    now = DateTime.utc_now()

    data =
      attrs
      |> Enum.map(fn row ->
        row
        |> Map.put("created_at", row["created_at"] * 1000 |> DateTime.from_unix!(:microsecond))
        |> Map.put("updated_at", row["updated_at"] * 1000 |> DateTime.from_unix!(:microsecond))
        |> Map.put("created_at_server", now)
        |> Map.put("updated_at_server", now)
        |> Map.take(["id", "title", "content", "likes", "created_at", "updated_at", "created_at_server", "updated_at_server", "push_id"])
        |> key_to_atom()
      end)

    Multi.insert_all(multi, name, Post, data,
      conflict_target: :id,
      on_conflict: {:replace_all_except, [:id, :version_created, :created_at_server, :deleted_at_server]},
      returning: true
    )
  end

  def key_to_atom(map) do
    Enum.reduce(map, %{}, fn
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
    end)
  end

  def record_deleted_posts(%Multi{} = multi, deleted_ids, _push_id) when is_nil(deleted_ids),
    do: multi

  def record_deleted_posts(%Multi{} = multi, deleted_ids, push_id) do
    now = DateTime.utc_now()

    data =
      deleted_ids
      |> Enum.map(fn id ->
        %{id: id, deleted_at_server: now, push_id: push_id}
      end)

    Multi.insert_all(multi, :delete_posts, Post, data,
      conflict_target: :id,
      on_conflict: {:replace, [:deleted_at_server, :version, :push_id]},
      returning: true
    )
  end

  def list_posts_changes(last_pulled_version, push_id) do
    posts_latest =
      Post
      |> where([p], p.version_created > ^last_pulled_version or p.version > ^last_pulled_version)
      |> Repo.all()

    posts_changes =
      posts_latest
      |> Enum.reject(fn post -> is_just_pushed(post, push_id) end)
      |> Enum.group_by(fn post ->
        cond do
          post.version_created > last_pulled_version and is_nil(post.deleted_at_server) -> :created
          post.created_at_server != post.updated_at_server and is_nil(post.deleted_at_server) -> :updated
          not is_nil(post.deleted_at_server) -> :deleted
        end
      end)
      |> Map.update(:created, [], fn posts -> posts end)
      |> Map.update(:updated, [], fn posts -> posts end)
      |> Map.update(:deleted, [], fn posts -> posts |> Enum.map(fn post -> post.id end) end)

    latest_version = find_latest_version(posts_latest)

    %{latest_version: latest_version, changes: posts_changes}
  end

  defp find_latest_version(posts) do
    posts
    |> Enum.flat_map(fn post -> [post.version, post.version_created] end)
    |> Enum.max(fn -> 0 end)
  end

  # ...
  defp set_push_id(posts, push_id) do
    posts
    |> Enum.map(fn post -> post |> Map.put("push_id", push_id) end)
  end
  # ...
  defp is_just_pushed(_post, push_id) when is_nil(push_id), do: false
  defp is_just_pushed(post, push_id), do: post.push_id == push_id
end
