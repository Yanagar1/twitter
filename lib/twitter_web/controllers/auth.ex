defmodule TwitterWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias TwitterWeb.Router.Helpers, as: Routes

  @spec init(keyword()) :: keyword()
  def init(opts), do: opts

  # opts most likely keyword
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      conn.assigns[:current_user] ->
        conn

      user = user_id && Twitter.Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  @doc """
  start a session and make a user the :current_user
  """
  @spec signin(Plug.Conn.t(), User.t()) :: Plug.Conn.t()
  def signin(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  @doc """
  sign out: end session
  """
  @spec signout(Plug.Conn.t()) :: Plug.Conn.t()
  def signout(conn) do
    configure_session(conn, drop: true)
  end

  import Phoenix.Controller
  alias TwitterWeb.Router.Helpers, as: Routes

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
