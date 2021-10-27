defmodule TwitterWeb.PageControllerTest do
  use TwitterWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    # this fails because of custom welcome message
    assert html_response(conn, 200) =~ "Welcome!"
  end
end
