defmodule TwitterWeb.Auth do
  import Plug.Conn

  @spec init(keyword()) :: keyword()
  def init(opts), do: opts

  # opts most likely keyword
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Twitter.Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  @spec signin(Plug.Conn.t(), User.t()) :: Plug.Conn.t()
  def signin(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  @spec signout(Plug.Conn.t()) :: Plug.Conn.t()
  def signout(conn) do
    configure_session(conn, drop: true)
  end
end
