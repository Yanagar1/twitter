defmodule TwitterWeb.BrowseViewTest do
  use TwitterWeb.ConnCase, async: true
  import Phoenix.View

  setup %{conn: conn} do
    author = user_fixture()
    reader = user_fixture()
    conn = init_test_session(conn, current_user: author, user_id: author.id)

    posts = [
      post_fixture(author, %{body: "i love you"}),
      post_fixture(author, %{body: "i dont love you"})
    ]

    conn = clear_session(conn)

    conn = init_test_session(conn, current_user: reader, user_id: reader.id)

    %{conn: conn, author: author, reader: reader, posts: posts}
  end

  test "renders index.html", %{conn: conn, posts: posts} do
    content = render_to_string(TwitterWeb.BrowseView, "index.html", conn: conn, posts: posts)
    assert String.contains?(content, "Listing Posts")

    for post <- posts do
      assert String.contains?(content, post.body)
    end
  end
end
