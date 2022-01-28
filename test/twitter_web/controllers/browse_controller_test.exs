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
      # check that flash appeared
      assert get_flash(conn)["info"] == "You liked this"

      # check if like exists in the db
      query =
        from like in Twits.Like, where: like.post_id == ^post.id and like.user_id == ^reader.id

      assert Twitter.Repo.exists?(query) == true

      # check if I can like it again
      conn = post(conn, Routes.browse_like_path(conn, :like, author.id, post.id))
      assert get_flash(conn)["info"] == "Couldn't send like"

      assert redirected_to(conn) == Routes.browse_path(conn, :show, author.id, post.id)
    end

    test "unlike a post", %{conn: conn, post: post, author: author, reader: reader} do
      Twits.create_like(reader, author.id, post.id)
      conn = delete(conn, Routes.browse_unlike_path(conn, :unlike, author.id, post.id))
      # check that flash appeared
      assert get_flash(conn)["info"] == "Like removed"

      # check like doesn't exist in db
      query =
        from like in Twits.Like, where: like.post_id == ^post.id and like.user_id == ^reader.id

      assert Twitter.Repo.exists?(query) == false

      # try to delete again
      assert_raise Ecto.NoResultsError, fn ->
        delete(conn, Routes.browse_unlike_path(conn, :unlike, author.id, post.id))
      end

      assert redirected_to(conn) == Routes.browse_path(conn, :show, author.id, post.id)
    end
  end

  describe "on failed log in" do
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
