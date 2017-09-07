defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  alias Discuss.Topic

  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    conn
    |> assign(:topics, Repo.all(Topic))
    |> render("index.html")
  end

  def show do
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{user: conn.assigns.user}, %{})

    conn
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  def create(conn, %{"topic" => topic}) do
    conn.assigns.user
    |> Ecto.build_assoc(:topics)
    |> Topic.changeset(topic)
    |> Repo.insert
    |> case do
      {:ok, _topic} ->
        index(conn, %{})
      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)

    conn
    |> assign(:topic, topic)
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Topic updated")
        |> assign(:topic, old_topic)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic ##{topic_id} deleted.")
    |> redirect(to: topic_path(conn, :index))
  end

  defp check_topic_owner(%{params: %{"id" => topic_id}} = conn, _params) do
    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You can't do this")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end
