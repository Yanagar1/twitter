defmodule TwitterWeb.PostController do
  use TwitterWeb, :controller
  alias Twitter.Twits
  alias Twitter.Twits.Post
  # all these are for signed in users
  # all require current_user to be the author
  plug :authenticate_user

  @doc """
  show all posts made by the logged in user, aka "my posts"
  """
  @spec index(Plug.Conn.t(), any, User.t()) :: Plug.Conn.t()
  def index(conn, _params, current_user) do
    posts = Twits.list_posts_by_author_id(current_user.id)
    render(conn, "index.html", posts: posts)
  end

  @doc """
  show form-page to enter my new post
  """
  @spec new(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def new(conn, _params, _current_user) do
    changeset = Post.changeset(%Post{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  submit the new post or reload the form-page on error
  """
  @spec create(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def create(conn, %{"post" => post_params}, current_user) do
    case Twits.create_post(current_user, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @doc """
  show just one specific post.
  """
  @spec show(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def show(conn, %{"post_id" => post_id}, current_user) do
    post = Twits.get_post!(current_user.id, post_id)
    render(conn, "show.html", post: post)
  end

  @doc """
  load one specific post in editable form
  """
  @spec edit(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def edit(conn, %{"post_id" => post_id}, current_user) do
    post = Twits.get_post!(current_user.id, post_id)
    changeset = Post.changeset(post, %{})
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  @doc """
  resubmit the edited post
  """
  @spec update(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def update(conn, %{"post_id" => post_id, "post" => post_params}, current_user) do
    case Twits.update_post(current_user, post_id, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: changeset.data, changeset: changeset)
    end
  end

  @doc """
  delete post by its id
  """
  @spec delete(Plug.Conn.t(), map(), User.t()) :: Plug.Conn.t()
  def delete(conn, %{"post_id" => post_id}, current_user) do
    {:ok, _post} = Twits.delete_post(current_user, post_id)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end
end
