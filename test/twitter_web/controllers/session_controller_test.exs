defmodule TwitterWeb.SessionControllerTest do
  use TwitterWeb.ConnCase

  @pass "123456"
  @incorrect_pass "123457"
  # creates user in db but doesn't log in
  setup %{conn: conn} do
    %{conn: conn, user: user_fixture(password: @pass)}
  end

  test ":new GET /sessions/new  renders sessions/new.html", %{conn: conn} do
    conn = get(conn, Routes.session_path(conn, :new))
    assert html_response(conn, 200) =~ "Sign in"
  end

  describe ":create POST /sessions " do
    test "redirects on passed authentication", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.session_path(conn, :create),
          session: %{username: user.username, password: @pass}
        )

      assert get_flash(conn)["info"] == "Welcome back!"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "renders sessions/new.html on failed authentication", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.session_path(conn, :create),
          session: %{username: user.username, password: @incorrect_pass}
        )

      assert get_flash(conn)["error"] == "Invalid username/password combination"
      assert html_response(conn, 200) =~ "Sign in"
    end
  end

  test ":delete DELETE /sessions/:id redirects to index", %{conn: conn, user: user} do
    conn =
      conn
      |> init_test_session(current_user: user, user_id: user.id, current_user_id: 1)
      |> delete(Routes.session_path(conn, :delete, :current_user_id))

    assert redirected_to(conn) == Routes.page_path(conn, :index)
  end
end
