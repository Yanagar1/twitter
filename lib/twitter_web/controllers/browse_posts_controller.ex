defmodule TwitterWeb.BrowseController do
  use TwitterWeb, :controller
  alias Twitter.Twits

  plug :authenticate_user

  @doc """
  list all posts made by any user
  """
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, %{"author_id" => author_id}) do
    posts = Twits.list_posts_by_author_id(author_id)
    render(conn, "index.html", posts: posts)
  end
end
