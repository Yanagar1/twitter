defmodule TwitterWeb.PostViewTest do
  use TwitterWeb.ConnCase, async: true
  alias Twitter.Accounts.User
  alias Twitter.Twits.Post
  import Phoenix.View

  setup %{conn: conn} do
    user = user_fixture()
    conn = init_test_session(conn, current_user: user, user_id: user.id)
    %{conn: conn, user: user}
  end

  test "renders index.html", %{conn: conn, user: user} do
    posts = [post_fixture(user), post_fixture(user)]
    content = render_to_string(TwitterWeb.PostView, "index.html", conn: conn, posts: posts)
    assert String.contains?(content, "Listing Posts")

    for post <- posts do
      assert String.contains?(content, post.body)
    end
  end

  test "renders form through new.html", %{conn: conn} do
    changeset = Post.changeset(%Post{}, %{})

    content =
      render_to_string(
        TwitterWeb.PostView,
        "new.html",
        conn: conn,
        changeset: changeset
      )

    assert String.contains?(content, "New Post")
  end

  test "render show.html", %{conn: conn, user: user} do
    post = post_fixture(user)
    content = render_to_string(TwitterWeb.PostView, "show.html", conn: conn, post: post)
    assert String.contains?(content, "Show Post")
  end

  test "render form through edit.html", %{conn: conn, user: user} do
    post = post_fixture(user)
    changeset = Post.changeset(%Post{}, %{})

    content =
      render_to_string(
        TwitterWeb.PostView,
        "edit.html",
        conn: conn,
        post: post,
        changeset: changeset
      )

    assert String.contains?(content, "Edit Post")
  end
end
