defmodule TwitterWeb.LikeControllerTest do
  use TwitterWeb.ConnCase
  alias Twitter.Twits

  setup %{conn: conn} do
    # make post
    author = user_fixture()
    liker = user_fixture()
    {:ok, post} = Twits.create_post(author, %{body: "some body"})

    # login
    conn = init_test_session(conn, current_user: liker, user_id: liker.id)
    like = [Twits.create_like(liker, post.id)]

    %{conn: conn, post: post, author: author, liker: liker}
  end

  test "index on success log in", %{conn: conn, post: post} do
    conn = get(conn, Routes.like_path(conn, :index, post.id))
    assert html_response(conn, 200) =~ "Listing Likes"
  end

  test "index on failed log in", %{conn: conn, post: post} do
    conn =
      conn
      |> clear_session()
      |> get(Routes.like_path(conn, :index, post.id))

    assert redirected_to(conn) == Routes.page_path(conn, :index)
  end

  test "create on success log in", %{conn: conn, post: post, author: author} do
    conn = post(conn, Routes.like_path(conn, :create, post.id))
    assert redirected_to(conn) == Routes.browse_path(conn, :index, author.id)
  end

  test "create on failed log in", %{conn: conn, post: post} do
    conn =
      conn
      |> clear_session()
      |> get(Routes.like_path(conn, :create, post.id))

    assert redirected_to(conn) == Routes.page_path(conn, :index)
  end

  test "delete on success log in", %{conn: conn, post: post, author: author} do
    conn = delete(conn, Routes.like_path(conn, :delete, post.id))
    assert redirected_to(conn) == Routes.browse_path(conn, :index, author.id)
  end

  test "delete on failed log in", %{conn: conn, post: post} do
    conn =
      conn
      |> clear_session()
      |> get(Routes.like_path(conn, :delete, post.id))

    assert redirected_to(conn) == Routes.page_path(conn, :index)
  end
end
