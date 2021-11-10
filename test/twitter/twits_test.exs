defmodule Twitter.TwitsTest do
  use Twitter.DataCase

  alias Twitter.Twits

  describe "posts" do
    alias Twitter.Twits.Post

    @valid_attrs %{" body": "some  body"}
    @update_attrs %{" body": "some updated  body"}
    @invalid_attrs %{" body": nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Twits.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Twits.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Twits.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Twits.create_post(@valid_attrs)
      assert post. body == "some  body"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Twits.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Twits.update_post(post, @update_attrs)
      assert post. body == "some updated  body"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Twits.update_post(post, @invalid_attrs)
      assert post == Twits.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Twits.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Twits.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Twits.change_post(post)
    end
  end
end
