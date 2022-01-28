defmodule TwitterWeb.BrowseViewTest do
  use TwitterWeb.ConnCase, async: true
  import Phoenix.View
  alias Twitter.Twits

  setup %{conn: conn} do
    author = user_fixture()
    reader = user_fixture()

    {:ok, post} = Twits.create_post(author, %{body: "i love you"})
    Twits.create_like(reader, author.id, post.id)

    # this preloads stuff
    posts = [Twits.get_post!(author.id, post.id)]

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

  test "renders show.html", %{conn: conn, posts: posts} do
    [post] = posts
    content = render_to_string(TwitterWeb.BrowseView, "show.html", conn: conn, post: post)
    assert String.contains?(content, "Show Public Post")

    for like <- post.likes do
      assert String.contains?(content, like.user.username)
    end
  end
end
