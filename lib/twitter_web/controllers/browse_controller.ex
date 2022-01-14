defmodule TwitterWeb.BrowseController do
  use TwitterWeb, :controller
  alias Twitter.Twits
  alias Twitter.Twits.Post
  import Ecto.Query, warn: false
  alias Twitter.Repo

  plug :authenticate_user

  @doc """
  list all posts made by any user
  """
  @spec index(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def index(conn, %{"author_id" => author_id}, _current_user) do
    posts = Twits.list_posts_by_author_id(author_id)
    render(conn, "index.html", posts: posts)
  end

  @doc """
  show a public post /browse/author_id/post_id
  """
  @spec show(Plug.Conn.t(), map(), User.t()) :: Plug.Connt.t()
  def show(conn, %{"author_id" => author_id, "id" => id}, _current_user) do
    post = Repo.one!(from p in Post, where: p.user_id == ^author_id, where: p.id == ^id)
    render(conn, "show.html", post: post)
  end

  @doc """
  add like for a given post_id. Here, browse_id is the post_id
  """
  @spec like(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def like(conn, %{"author_id" => author_id, "browse_id" => browse_id}, current_user) do
    case Twits.create_like(current_user, browse_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "You liked this")

      {:error, _} ->
        conn
        |> put_flash(:info, "Couldn't send like")
    end

    # return to :show post made by author
    conn = redirect(conn, to: Routes.browse_path(conn, :show, author_id, browse_id))
  end

  @doc """
  delete like for a given post
  """
  @spec unlike(Plug.Connt.t(), map(), User.t()) :: Plug.Conn.t()
  def unlike(conn, %{"author_id" => author_id, "browse_id" => browse_id}, current_user) do
    case Twits.delete_like(current_user, browse_id) do
      {:ok, _} ->
        conn = put_flash(conn, :info, "Like removed")

      {:error, _} ->
        conn = put_flash(conn, :info, "Couldn't delete like")
    end

    # return to :show post made by author
    conn = redirect(conn, to: Routes.browse_path(conn, :show, author_id, browse_id))
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end
end
