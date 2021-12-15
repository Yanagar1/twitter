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

    test "list_posts_by_author_id/1 returns all posts of a given author", %{user: user} do
      # equivalent to list_posts when own id is passed
      post = post_fixture(user)
      assert post = Twits.list_posts_by_author_id(user.id)
    end

    test "get_post!/2 returns the post with given id", %{user: user} do
      %Post{id: id} = post_fixture(user)
      assert %Post{id: ^id} = Twits.get_post!(user, id)
    end

    test "create_post/2 with valid data creates a post", %{user: user} do
      assert {:ok, %Post{} = post} = Twits.create_post(user, @valid_attrs)
      assert post.body == "some body"
    end

    test "create_post/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Twits.create_post(user, @invalid_attrs)
    end

    test "update_post/2 with valid data updates the post", %{user: user} do
      post = post_fixture(user)
      assert {:ok, %Post{} = post} = Twits.update_post(post, @update_attrs)
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset", %{user: user} do
      post = post_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Twits.update_post(post, @invalid_attrs)
      assert post = Twits.get_post!(user, post.id)
    end

    test "delete_post/1 deletes the post", %{user: user} do
      post = post_fixture(user)
      assert {:ok, %Post{}} = Twits.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Twits.get_post!(user, post.id) end
    end

    test "change_post/1 returns a post changeset", %{user: user} do
      post = post_fixture(user)
      assert %Ecto.Changeset{} = Twits.change_post(post)
    end
  end

  describe "likes" do
    setup %{conn: conn} do
      author = user_fixture()
      conn = init_test_session(conn, current_user: author, user_id: author.id)
      post = post_fixture(author)
      conn = clear_session(conn)

      liker = user_fixture()
      conn = init_test_session(conn, current_user: liker, user_id: liker.id)
      %{conn: conn, author: author, post: post, liker: liker}
    end

    test "list_likes_by_post_id(post_id)", %{post: post} do
      assert likes = Twits.list_likes_by_post_id(post.id)
      assert length(likes) == 0
    end

    test "create like and attempt to like twice", %{post: post, liker: liker} do
      assert {:ok, _like} = Twits.create_like(liker, post.id)
      assert liker.id != post.user_id
      assert Twits.create_like(liker, post.id) == true
    end

    test "delete like then delete again", %{post: post, liker: liker} do
      {:ok, like} = Twits.create_like(liker, post.id)
      {:ok, del_like} = Twits.delete_like(liker, post.id)
      assert like.id == del_like.id
      assert Twits.delete_like(liker, post.id) == false
    end
  end
end
