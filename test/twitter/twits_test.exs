defmodule Twitter.TwitsTest do
  use TwitterWeb.ConnCase
  # use Twitter.DataCase, async: true
  # alias Twitter.Accounts.User
  alias Twitter.Twits

  describe "posts" do
    alias Twitter.Twits.Post

    @valid_attrs %{body: "some body"}
    @update_attrs %{body: "some updated body"}
    @invalid_attrs %{body: nil}

    setup %{conn: conn} do
      user = user_fixture()
      conn = init_test_session(conn, current_user: user, user_id: user.id)
      %{conn: conn, user: user}
    end

    test "list_posts/1 returns all posts of current user", %{user: user} do
      post = post_fixture(user)
      assert post = Twits.list_posts(user)
    end

    test "get_post!/2 returns the post with given id", %{user: user} do
      %Post{id: id} = post_fixture(user)
      assert %Post{id: ^id} = Twits.get_post!(user, id)
    end

    test "create_post/2 with valid data creates a post", %{conn: conn, user: user} do
      assert {:ok, %Post{} = post} = Twits.create_post(user, @valid_attrs)
      assert post.body == "some body"
    end

    test "create_post/2 with invalid data returns error changeset", %{conn: conn, user: user} do
      assert {:error, %Ecto.Changeset{}} = Twits.create_post(user, @invalid_attrs)
    end

    test "update_post/2 with valid data updates the post", %{conn: conn, user: user} do
      post = post_fixture(user)
      assert {:ok, %Post{} = post} = Twits.update_post(post, @update_attrs)
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset", %{conn: conn, user: user} do
      post = post_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Twits.update_post(post, @invalid_attrs)
      assert post = Twits.get_post!(user, post.id)
    end

    test "delete_post/1 deletes the post", %{conn: conn, user: user} do
      post = post_fixture(user)
      assert {:ok, %Post{}} = Twits.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Twits.get_post!(user, post.id) end
    end

    test "change_post/1 returns a post changeset", %{conn: conn, user: user} do
      post = post_fixture(user)
      assert %Ecto.Changeset{} = Twits.change_post(post)
    end
  end
end
