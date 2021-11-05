defmodule TwitterWeb.LayoutViewTest do
  use TwitterWeb.ConnCase, async: true
  import Phoenix.View
  # When testing helpers, you may want to import Phoenix.HTML and
  # use functions such as safe_to_string() to convert the helper
  # result into an HTML string.
  # import Phoenix.HTML

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(TwitterWeb.Router, :browser)
      |> get("/")

    %{conn: conn}
  end

  test "renders app.html", %{conn: conn} do
    # what is inner content?
    inner_content = []

    content =
      render_to_string(
        TwitterWeb.LayoutView,
        "app.html",
        conn: conn,
        current_user: nil,
        inner_content: inner_content
      )

    assert String.contains?(content, "Twitter")
  end
end
