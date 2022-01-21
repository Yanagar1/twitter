defmodule Twitter.TwitsTest do
  use Twitter.DataCase, async: true
  alias Twitter.Twits
  import Ecto.Query

  alias Twitter.Twits.Post

  @valid_attrs %{body: "some body"}
  @update_attrs %{body: "some updated body"}
  @invalid_attrs %{body: nil}

  setup do
    author = user_fixture()
    liker = user_fixture()
    {:ok, post} = Twits.create_post(author, @valid_attrs)
    %{author: author, post: post, liker: liker}
  end

  test "list_posts_by_author_id/1 returns all posts of a given author", %{
    author: author,
    post: post
  } do
    # shows my posts when current_user.id is passed
    # post made is the post returned
    [post2] = Twits.list_posts_by_author_id(author.id)
    assert post.id == post2.id
  end

  test "get_post!/2 returns the post with given id and preloaded likes, user", %{
    author: author,
    post: post,
    liker: liker
  } do
    Twits.create_like(liker, author.id, post.id)
    post_returned = Twits.get_post!(author.id, post.id)
    assert post.id == post_returned.id
    assert length(post_returned.likes) == 1
    [like] = post_returned.likes
    assert like.user.username == liker.username
  end

  test "create_post/2 with valid data creates a post", %{author: author} do
    assert {:ok, %Post{} = post} = Twits.create_post(author, @valid_attrs)
    assert post.body == "some body"
    assert post.user_id == author.id

    # check if post exists in the db
    query = from p in Post, where: p.id == ^post.id
    assert Twitter.Repo.exists?(query) == true
  end

  test "create_post/2 with invalid data returns error changeset", %{author: author} do
    assert {:error, %Ecto.Changeset{}} = Twits.create_post(author, @invalid_attrs)
  end

  test "update_post/2 with valid data updates the post", %{author: author, post: post} do
    assert {:ok, %Post{} = post} = Twits.update_post(author, post.id, @update_attrs)
    assert post.body == "some updated body"
  end

  test "update_post/2 with invalid data returns error changeset", %{author: author, post: post} do
    assert {:error, %Ecto.Changeset{}} = Twits.update_post(author, post.id, @invalid_attrs)
  end

  test "delete_post/1 deletes the post", %{author: author, post: post} do
    assert {:ok, %Post{}} = Twits.delete_post(author, post.id)
    assert_raise Ecto.NoResultsError, fn -> Twits.get_post!(author.id, post.id) end
  end

  test "create like; try like twice returns error", %{post: post, liker: liker, author: author} do
    assert {:ok, _like} = Twits.create_like(liker, author.id, post.id)
    assert liker.id != post.user_id
    assert {:error, _like_changeset} = Twits.create_like(liker, author.id, post.id)
  end

  test "delete like; try deleting non-existent like -> no results error", %{
    post: post,
    liker: liker,
    author: author
  } do
    {:ok, like} = Twits.create_like(liker, author.id, post.id)
    {:ok, del_like} = Twits.delete_like(liker, post.id)
    assert like.id == del_like.id
    assert Twitter.Repo.exists?(from l in Twits.Like, where: l.id == ^like.id) == false
    assert_raise Ecto.NoResultsError, fn -> Twits.delete_like(liker, post.id) end
  end
end
