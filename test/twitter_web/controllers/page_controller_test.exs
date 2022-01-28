defmodule TwitterWeb.PageControllerTest do
  use TwitterWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome, Rap Birds!"
  end
end
