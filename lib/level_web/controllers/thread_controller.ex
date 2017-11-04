defmodule LevelWeb.ThreadController do
  use LevelWeb, :controller

  def index(conn, _params) do
    user = conn.assigns[:current_user]
    api_token = LevelWeb.Auth.generate_signed_jwt(user)
    render conn, "index.html", api_token: api_token
  end
end