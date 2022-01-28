defmodule TwitterWeb.UserControllerTest do
  use TwitterWeb.ConnCase

  @pass "123456"
  @create_inval_attrs %{name: nil, username: nil, password: nil, email: nil}

  setup %{conn: conn} do
    %{conn: conn, user: user_fixture(password: @pass)}
  end

  describe "index GET /users" do
    test "redirects to GET / on failed authenticate(conn, _opts)", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      # test for the flash message?
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "loads on passed authenticate(conn, _opts)", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(current_user: user, user_id: user.id)
        |> get(Routes.user_path(conn, :index))

      assert html_response(conn, 200) =~ "Search users"
    end
  end

  describe("show GET /users/:id") do
    test "redirects to GET / on failed authenticate(conn, _opts)", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user.id))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "loads on passed authenticate(conn, _opts)", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(current_user: user, user_id: user.id)
        |> get(Routes.user_path(conn, :show, user.id))

      assert html_response(conn, 200) =~ "Show User"
    end
  end

  describe("create POST /users") do
    @create_valid_attrs %{name: "yana", username: "bird", password: @pass, email: "nonempty"}

    test "creates session, renders index.html", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_valid_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :create)
    end

    test "renders new.html on error", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_inval_attrs)
      assert html_response(conn, 200) =~ "New user"
    end
  end

  test "new GET /users/new returns conn with new.html", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :new))
    assert html_response(conn, 200) =~ "New user"
  end
end
