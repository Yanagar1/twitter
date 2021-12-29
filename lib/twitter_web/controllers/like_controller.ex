defmodule TwitterWeb.LikeController do
  use TwitterWeb, :controller
  import Ecto.Query, warn: false
  alias Twitter.Twits
  alias Twitter.Repo
  plug :authenticate_user

  @doc """
  return all likes for a given post
  """
  @spec index(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def index(conn, %{"post_id" => post_id}, _current_user) do
    likes = Twits.list_likes_by_post_id(post_id)
    render(conn, "index.html", likes: likes)
  end

  @doc """
  add like for a given post_id
  """
  @spec create(Plug.Connt.t(), map(), User.t()) :: Plug.Conn.t()
  def create(conn, %{"post_id" => post_id}, current_user) do
    case Twits.create_like(current_user, post_id) do
      {:ok, _} ->
        conn = put_flash(conn, :info, "You liked this")

      {:error, _} ->
        conn = put_flash(conn, :info, "Couldn't send like")
    end

    # return to all posts made by author, because I don't have :show method in browse
    %{user_id: author_id} = Repo.get(Twits.Post, post_id)
    conn = redirect(conn, to: Routes.browse_path(conn, :index, author_id))
  end

  @doc """
  delete like for a given post
  """
  @spec delete(Plug.Connt.t(), map(), User.t()) :: Plug.Conn.t()
  def delete(conn, %{"post_id" => post_id}, current_user) do
    case Twits.delete_like(current_user, post_id) do
      {:ok, _} ->
        conn = put_flash(conn, :info, "Like removed")

      {:error, _} ->
        conn = put_flash(conn, :info, "Couldn't delete like")
    end

    # return to all posts made by author, because I don't have :show method in browse
    %{user_id: author_id} = Repo.get(Twits.Post, post_id)
    conn = redirect(conn, to: Routes.browse_path(conn, :index, author_id))
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end
end
