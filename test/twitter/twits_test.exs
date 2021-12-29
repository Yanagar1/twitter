defmodule Twitter.TwitsTest do
  use Twitter.DataCase, async: true
  alias Twitter.Twits
  import Ecto.Query

  describe "posts" do
    alias Twitter.Twits.Post

    @valid_attrs %{body: "some body"}
    @update_attrs %{body: "some updated body"}
    @invalid_attrs %{body: nil}

    setup do
      user = user_fixture()
      {:ok, post} = Twits.create_post(user, @valid_attrs)
      %{user: user, post: post}
    end

    test "list_posts/1 returns all posts of current user", %{user: user, post: post} do
      assert post = Twits.list_posts(user)
    end

    test "list_posts_by_author_id/1 returns all posts of a given author", %{
      user: user,
      post: post
    } do
      # equivalent to list_posts when own id is passed
      assert post = Twits.list_posts_by_author_id(user.id)
    end

    test "get_post!/2 returns the post with given id", %{user: user, post: post} do
      %Post{id: id} = post
      assert %Post{id: ^id} = Twits.get_post!(user, id)
    end

    test "create_post/2 with valid data creates a post", %{user: user} do
      assert {:ok, %Post{} = post} = Twits.create_post(user, @valid_attrs)
      assert post.body == "some body"
      assert post.user_id == user.id

      # check if post exists in the db
      query = from p in Post, where: p.id == ^post.id
      assert Twitter.Repo.exists?(query) == true
    end

    test "create_post/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Twits.create_post(user, @invalid_attrs)
    end

    test "update_post/2 with valid data updates the post", %{user: user, post: post} do
      assert {:ok, %Post{} = post} = Twits.update_post(user, post.id, @update_attrs)
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset", %{user: user, post: post} do
      assert {:error, %Ecto.Changeset{}} = Twits.update_post(user, post.id, @invalid_attrs)
    end

    test "delete_post/1 deletes the post", %{user: user, post: post} do
      assert {:ok, %Post{}} = Twits.delete_post(user, post.id)
      assert_raise Ecto.NoResultsError, fn -> Twits.get_post!(user, post.id) end
    end
  end

  describe "likes" do
    setup do
      author = user_fixture()
      liker = user_fixture()
      {:ok, post} = Twits.create_post(author, %{body: "some body"})

      %{author: author, post: post, liker: liker}
    end

    test "list_likes_by_post_id(post_id) checks that list of likes is returned", %{post: post} do
      assert likes = Twits.list_likes_by_post_id(post.id)
      assert length(likes) == 0
    end

    test "create like; try like twice returns error", %{post: post, liker: liker} do
      assert {:ok, _like} = Twits.create_like(liker, post.id)
      assert liker.id != post.user_id
      assert {:error, _like_changeset} = Twits.create_like(liker, post.id)
    end

    test "delete like; try deleting non-existent like -> no results error", %{
      post: post,
      liker: liker
    } do
      {:ok, like} = Twits.create_like(liker, post.id)
      {:ok, del_like} = Twits.delete_like(liker, post.id)
      assert like.id == del_like.id
      assert Twitter.Repo.exists?(from l in Twits.Like, where: l.id == ^like.id) == false
      assert_raise Ecto.NoResultsError, fn -> Twits.delete_like(liker, post.id) end
    end
  end
end
