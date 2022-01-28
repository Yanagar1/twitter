defmodule TwitterWeb.PostControllerTest do
  use TwitterWeb.ConnCase
  alias Twitter.Twits
  @create_attrs %{body: "some body"}
  @update_attrs %{body: "some updated body"}
  @invalid_attrs %{body: nil}

  describe "successfully logged in access" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = init_test_session(conn, current_user: user, user_id: user.id)
      post = post_fixture(user)
      %{conn: conn, post: post, user: user}
    end

    test "index: lists all current user's posts", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Posts"
    end

    test "new: renders form", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :new))
      assert html_response(conn, 200) =~ "New Post"
    end

    test "create post: redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)
      assert get_flash(conn)["info"] == "Post created successfully."
      assert %{post_id: post_id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.post_path(conn, :show, post_id)
    end

    test "create post: render form when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end

    test "show: one of my posts on successfull login", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :show, post.id))

      assert html_response(conn, 200) =~ "Show Post"
    end

    test "edit: renders form for editing chosen post", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :edit, post.id))
      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "update: redirects when data is valid", %{conn: conn, post: post} do
      conn = put(conn, Routes.post_path(conn, :update, post.id), post: @update_attrs)
      assert get_flash(conn)["info"] == "Post updated successfully."
      assert redirected_to(conn) == Routes.post_path(conn, :show, post)
      conn = get(conn, Routes.post_path(conn, :show, post.id))
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "update: render edit.html when data is invalid", %{conn: conn, post: post} do
      conn = put(conn, Routes.post_path(conn, :update, post.id), post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "delete: chosen post", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.id))
      assert get_flash(conn)["info"] == "Post deleted successfully."
      assert redirected_to(conn) == Routes.post_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.post_path(conn, :show, post))
      end
    end
  end

  describe "refuse if not signed in" do
    setup %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user)
      %{conn: conn, post: post, user: user}
    end

    test "index", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert get_flash(conn)["error"] == "You must be logged in to access that page"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "new", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :new))
      assert get_flash(conn)["error"] == "You must be logged in to access that page"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "create", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)
      assert get_flash(conn)["error"] == "You must be logged in to access that page"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "show", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :show, post.id))
      assert get_flash(conn)["error"] == "You must be logged in to access that page"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "edit", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :edit, post.id))
      assert get_flash(conn)["error"] == "You must be logged in to access that page"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "update", %{conn: conn, post: post} do
      conn = put(conn, Routes.post_path(conn, :update, post.id), post: @update_attrs)
      assert get_flash(conn)["error"] == "You must be logged in to access that page"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "delete", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.id))
      assert get_flash(conn)["error"] == "You must be logged in to access that page"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end

  describe "signed in but accessing someone else's posts" do
    setup %{conn: conn} do
      user_me = user_fixture()
      user_not_me = user_fixture()
      # not_me makes a post
      {:ok, not_my_post} = Twits.create_post(user_not_me, %{body: "some body"})

      # me enters
      conn = init_test_session(conn, current_user: user_me, user_id: user_me.id)
      post_fixture(user_me, %{body: "wuff wuff"})

      %{conn: conn, post: not_my_post, user1: user_me, user2: user_not_me}
    end

    test "index includes my_post and not not_my_post", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert html_response(conn, 200) =~ "wuff wuff"
      assert html_response(conn, 200) != "some body"
    end

    test "show, edit, update, delete", %{conn: conn, post: not_my_post} do
      assert_error_sent :not_found, fn ->
        get(conn, Routes.post_path(conn, :show, not_my_post.id))
      end

      assert_error_sent :not_found, fn ->
        get(conn, Routes.post_path(conn, :edit, not_my_post.id))
      end

      assert_error_sent :not_found, fn ->
        put(conn, Routes.post_path(conn, :update, not_my_post.id), post: @update_attrs)
      end

      assert_error_sent :not_found, fn ->
        delete(conn, Routes.post_path(conn, :delete, not_my_post.id))
      end
    end
  end
end
