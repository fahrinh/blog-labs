defmodule BlogAppWeb.SyncController do
  use BlogAppWeb, :controller
  alias BlogApp.Sync

  def push(
        %Plug.Conn{
          body_params: req_body,
          query_params: %{"lastPulledVersion" => last_pulled_version}
        } = conn,
        _params
      ) do

    resp =  Sync.push(req_body, String.to_integer(last_pulled_version))
    json(conn, resp)
  end

  def pull(
        %Plug.Conn{
          query_params: %{"lastPulledVersion" => last_pulled_version}
        } = conn,
        _params
      ) do

    resp = Sync.pull(String.to_integer(last_pulled_version))
    json(conn, resp)
  end
end
