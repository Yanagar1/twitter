defmodule TwitterWeb.BrowseController do
  use TwitterWeb, :controller
  alias Twitter.Twits
  import Ecto.Query, warn: false

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
  def show(conn, %{"author_id" => author_id, "post_id" => post_id}, _current_user) do
    post = Twits.get_post!(author_id, post_id)
    render(conn, "show.html", post: post)
  end

  @doc """
  add like for a given post_id. Here, browse_post_id is the post_id
  """
  @spec like(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def like(conn, %{"author_id" => author_id, "browse_post_id" => browse_post_id}, current_user) do
    case Twits.create_like(current_user, author_id, browse_post_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "You liked this")
        |> redirect(to: Routes.browse_path(conn, :show, author_id, browse_post_id))

      {:error, _} ->
        conn
        |> put_flash(:info, "Couldn't send like")
        |> redirect(to: Routes.browse_path(conn, :show, author_id, browse_post_id))
    end
  end

  @doc """
  delete like for a given post
  """
  @spec unlike(Plug.Connt.t(), map(), User.t()) :: Plug.Conn.t()
  def unlike(conn, %{"author_id" => author_id, "browse_post_id" => browse_post_id}, current_user) do
    case Twits.delete_like(current_user, browse_post_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Like removed")
        |> redirect(to: Routes.browse_path(conn, :show, author_id, browse_post_id))

      {:error, _} ->
        conn
        |> put_flash(:info, "Couldn't delete like")
        |> redirect(to: Routes.browse_path(conn, :show, author_id, browse_post_id))
    end
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end
end
