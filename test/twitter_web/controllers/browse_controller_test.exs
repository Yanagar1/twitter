defmodule TwitterWeb.BrowseControllerTest do
  use TwitterWeb.ConnCase
  alias Twitter.Twits
  import Ecto.Query

  # make post from one user account, then relogin -> should still
  # see the post, as it is the public post controller
  setup %{conn: conn} do
    author = user_fixture()
    reader = user_fixture()

    {:ok, post} = Twits.create_post(author, %{body: "i love you"})

    %{conn: conn, post: post, author: author, reader: reader}
  end

  describe "index, show, like, unlike on successful log in" do
    # login as reader
    setup %{conn: conn, post: post, author: author, reader: reader} do
      conn = init_test_session(conn, current_user: reader, user_id: reader.id)
      like = [Twits.create_like(reader, post.id)]

      %{conn: conn, post: post, author: author, reader: reader}
    end

    test "index: lists all author's posts", %{conn: conn, author: author} do
      conn = get(conn, Routes.browse_path(conn, :index, author.id))
      assert html_response(conn, 200) =~ "i love you"
    end

    test "show: author's one post", %{conn: conn, author: author, post: post} do
      conn = get(conn, Routes.browse_path(conn, :show, author.id, post.id))
      assert html_response(conn, 200) =~ "i love you"
    end

    test "like a post", %{conn: conn, post: post, author: author, reader: reader} do
      conn = post(conn, Routes.browse_like_path(conn, :like, author.id, post.id))

      # check if like exists in the db
      query =
        from like in Twits.Like, where: like.post_id == ^post.id and like.user_id == ^reader.id

      assert Twitter.Repo.exists?(query) == true

      assert redirected_to(conn) == Routes.browse_path(conn, :show, author.id, post.id)
    end

    test "unlike a post", %{conn: conn, post: post, author: author} do
      conn = delete(conn, Routes.browse_unlike_path(conn, :unlike, author.id, post.id))
      assert redirected_to(conn) == Routes.browse_path(conn, :show, author.id, post.id)
    end
  end

  describe "index, show, like, unlike on failed log in" do
    setup %{conn: conn, post: post, author: author, reader: reader} do
      like = [Twits.create_like(reader, post.id)]

      %{conn: conn, post: post, author: author, reader: reader}
    end

    test "index", %{conn: conn, author: author} do
      conn = get(conn, Routes.browse_path(conn, :index, author.id))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "show", %{conn: conn, author: author, post: post} do
      conn = get(conn, Routes.browse_path(conn, :show, author.id, post.id))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "like", %{conn: conn, post: post, author: author} do
      conn = post(conn, Routes.browse_like_path(conn, :like, author.id, post.id))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "unlike", %{conn: conn, post: post, author: author} do
      conn = delete(conn, Routes.browse_unlike_path(conn, :unlike, author.id, post.id))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end
end
