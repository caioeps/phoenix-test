defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  def index do
  end

  def show do
  end

  def new(conn, _params) do
    conn
    |> assign :user, %{name: "Caio"}
    |> render "new.html"
  end

  def create do
  end

  def edit do
  end

  def update do
  end

  def destroy do
  end
end
