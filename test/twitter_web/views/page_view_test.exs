defmodule TwitterWeb.PageViewTest do
  use TwitterWeb.ConnCase, async: true
  import Phoenix.View

  setup %{conn: conn} do
    %{conn: conn}
  end

  test "render index.html", %{conn: conn} do
    content =
      render_to_string(
        TwitterWeb.PageView,
        "index.html",
        conn: conn
      )

    assert String.contains?(content, "Rap Birds")
  end
end
