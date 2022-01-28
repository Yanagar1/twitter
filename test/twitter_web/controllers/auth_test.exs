defmodule TwitterWeb.AuthTest do
  use TwitterWeb.ConnCase, async: true
  alias TwitterWeb.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(TwitterWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists",
       %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user for existing current_user",
       %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Twitter.Accounts.User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "signin puts the user in the session", %{conn: conn} do
    signin_conn =
      conn
      |> Auth.signin(%Twitter.Accounts.User{id: 123})
      |> send_resp(:ok, "")

    next_conn = get(signin_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "signout drops the session", %{conn: conn} do
    signout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.signout()
      |> send_resp(:ok, "")

    next_conn = get(signout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Auth.init([]))

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Auth.init([]))
    assert conn.assigns.current_user == nil
  end
end
