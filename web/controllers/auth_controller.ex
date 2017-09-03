defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  alias Discuss.User

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    user_params = %{
      github_token: auth.credentials.token,
      email: auth.info.nickname,
      provider: "github"
    }

    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  defp insert_or_update(changeset) do
    case Repo.get_by(User, Map.take(changeset, [:email, :provider])) do
      nil  -> Repo.insert(changeset)
      user -> {:ok, user}
    end
  end

  defp signin(conn, changeset) do
    case insert_or_update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:info, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end
end