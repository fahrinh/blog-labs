defmodule BlogApp.Repo do
  use Ecto.Repo,
    otp_app: :blog_app,
    adapter: Ecto.Adapters.Postgres
end
