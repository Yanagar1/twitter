defmodule TwitterWeb.UserViewTest do
  use TwitterWeb.ConnCase, async: true
  alias Twitter.Accounts.User
  import Phoenix.View

  setup %{conn: conn} do
    %{conn: conn}
  end

  test "renders index.html", %{conn: conn} do
    users = [
      user_fixture(),
      user_fixture()
    ]

    user1 = Enum.at(users, 0)
    conn = init_test_session(conn, current_user: user1, user_id: user1.id)

    content =
      render_to_string(
        TwitterWeb.UserView,
        "index.html",
        conn: conn,
        users: users
      )

    assert String.contains?(content, "Search users")

    for user <- users do
      assert String.contains?(content, user.username)
    end
  end

  test "render new.html", %{conn: conn} do
    changeset = User.changeset(%User{}, %{})

    content =
      render_to_string(
        TwitterWeb.UserView,
        "new.html",
        conn: conn,
        changeset: changeset
      )

    assert String.contains?(content, "New user")
  end

  # for now, these two return the same thing
  test "render show.html", %{conn: conn} do
    user = user_fixture()

    content =
      render_to_string(
        TwitterWeb.UserView,
        "show.html",
        conn: conn,
        user: user
      )

    assert String.contains?(content, "Showing user")
  end

  test "render user.html", %{conn: conn} do
    user = user_fixture()

    content =
      render_to_string(
        TwitterWeb.UserView,
        "user.html",
        conn: conn,
        user: user
      )

    assert String.contains?(content, user.username)
  end
end
