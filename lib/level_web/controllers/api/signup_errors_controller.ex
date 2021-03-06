defmodule LevelWeb.API.SignupErrorsController do
  @moduledoc false

  use LevelWeb, :controller

  alias Level.Spaces

  def index(conn, %{"signup" => params}) do
    changeset = Spaces.registration_changeset(%{}, params)
    render conn, "show.json", %{changeset: changeset}
  end
end
