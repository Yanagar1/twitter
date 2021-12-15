defmodule TwitterWeb.LikeViewTest do
  use TwitterWeb.ConnCase, async: true
  import Phoenix.View

  setup %{conn: conn} do
    author = user_fixture()
    reader = user_fixture()
    conn = init_test_session(conn, current_user: author, user_id: author.id)
    post = post_fixture(author, %{body: "i love you"})
    conn = clear_session(conn)

    conn = init_test_session(conn, current_user: reader, user_id: reader.id)
    {:ok, like} = Twitter.Twits.create_like(reader, post.id)
    likes = [like]

    %{conn: conn, author: author, reader: reader, post: post, likes: likes}
  end

  test "renders index.html", %{conn: conn, likes: likes} do
    content = render_to_string(TwitterWeb.LikeView, "index.html", conn: conn, likes: likes)
    assert String.contains?(content, "Listing Likes")

    for l <- likes do
      assert String.contains?(content, Kernel.inspect(l.user_id))
    end
  end
end
