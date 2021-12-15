defmodule Twitter.Twits do
  @moduledoc """
  The Twits context.
  Includes functions for posts and likes
  """

  import Ecto.Query, warn: false
  alias Twitter.Repo
  alias Twitter.Twits.Post
  alias Twitter.Twits.Like
  alias Twitter.Accounts

  defp user_posts_query(query, %Accounts.User{id: user_id}) do
    from p in query, where: p.user_id == ^user_id
  end

  @spec list_posts(User.t()) :: list(Post.t())
  @doc """
  Returns the list of posts. This fn is used for the current user.
  ## Examples
      iex> list_posts()
      [%Post{}, ...]
  """
  def list_posts(%Accounts.User{} = user) do
    Post
    |> user_posts_query(user)
    |> Repo.all()
  end

  @doc """
  list posts by author id
  """
  @spec list_posts_by_author_id(integer() | String.t()) :: list(Post.t())
  def list_posts_by_author_id(author_id) do
    Repo.all(from p in Post, where: p.user_id == ^author_id)
  end

  @spec get_post!(User.t(), integer() | String.t()) :: Post.t()
  @doc """
  Gets a single post: takes user and the post id
  Raises `Ecto.NoResultsError` if the Post does not exist.
  ## Examples
      iex> get_post!(123)
      %Post{}
      iex> get_post!(456)
      ** (Ecto.NoResultsError)
  """
  def get_post!(%Accounts.User{} = user, id) do
    Post
    |> user_posts_query(user)
    |> Repo.get!(id)
  end

  @spec create_post(User.t(), map()) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  @doc """
  Creates a post. current_user id is registered automatically
  ## Examples
      iex> create_post(%{field: value})
      {:ok, %Post{}}
      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_post(%Accounts.User{} = user, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @spec update_post(Post.t(), map()) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  @doc """
  Updates a post.
  ## Examples
      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}
      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_post(Post.t()) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  @doc """
  Deletes a post.
  ## Examples
      iex> delete_post(post)
      {:ok, %Post{}}
      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}
  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @spec change_post(Post.t(), map()) :: Ecto.Changeset.t(Post.t())
  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.
  ## Examples
      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}
  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  ################################################
  ############# LIKES ###########################
  ################################################
  defp likes_of_post_query(query, post_id) do
    from l in query, where: l.post_id == ^post_id
  end

  defp get_like_query(query, post_id, %Accounts.User{id: user_id}) do
    from l in query, where: l.post_id == ^post_id and l.user_id == ^user_id
  end

  @spec list_likes_by_post_id(integer() | String.t()) :: list(Like.t())
  @doc """
  Returns the likes of a post.
  """
  def list_likes_by_post_id(post_id) do
    Like
    |> likes_of_post_query(post_id)
    |> Repo.all()
  end

  @doc """
  like someone else's post: the post_id and current user should be passed
  current user will be assigned automatically with actions in like_controller
  """
  @spec create_like(User.t(), integer() | String.t()) :: Like.t()
  def create_like(%Accounts.User{} = user, post_id) do
    # check that it doesn't exist
    query = get_like_query(Like, post_id, user)

    with false <- Repo.exists?(query) do
      %Like{}
      |> Like.changeset(%{user_id: user.id, post_id: post_id})
      # |> Ecto.Changeset.put_assoc(:post, post)
      |> Repo.insert()
    end
  end

  @doc """
  unlike someone else's post, the post and current user should be passed
  """
  @spec delete_like(User.t(), integer() | String.t()) ::
          {:ok, Like.t()} | {:error, Ecto.Changeset.t(Like.t())}
  def delete_like(%Accounts.User{} = user, post_id) do
    # check that it exists
    query = get_like_query(Like, post_id, user)
    # calling the same query twice...
    with true <- Repo.exists?(query) do
      Like
      |> get_like_query(post_id, user)
      |> Repo.one()
      |> Repo.delete()
    end
  end
end
