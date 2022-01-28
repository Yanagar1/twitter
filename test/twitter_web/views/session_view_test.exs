defmodule TwitterWeb.SessionViewTest do
  use TwitterWeb.ConnCase, async: true
  import Phoenix.View

  setup %{conn: conn} do
    %{conn: conn}
  end

  test "renders new.html", %{conn: conn} do
    content =
      render_to_string(
        TwitterWeb.SessionView,
        "new.html",
        conn: conn
      )

    assert String.contains?(content, "Sign in")
  end
end
