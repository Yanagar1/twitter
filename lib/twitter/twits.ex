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

  defp user_posts_query(query, author_id) do
    from(p in query,
      where: p.user_id == ^author_id,
      preload: [:user, likes: :user],
      select: p
    )
  end

  @doc """
  list posts by author id
  """
  @spec list_posts_by_author_id(non_neg_integer() | String.t()) :: list(Post.t())
  def list_posts_by_author_id(author_id) do
    Post
    |> user_posts_query(author_id)
    |> Repo.all()
  end

  @doc """
  Gets a single post: takes user and the post id
  Raises `Ecto.NoResultsError` if the Post does not exist.
  """
  @spec get_post!(non_neg_integer() | String.t(), non_neg_integer() | String.t()) :: Post.t()
  def get_post!(author_id, post_id) do
    Post
    |> user_posts_query(author_id)
    |> Repo.get!(post_id)
  end

  @doc """
  Creates a post. current_user id is registered automatically
  ## Examples
      iex> create_post(%{field: value})
      {:ok, %Post{}}
      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_post(User.t(), map()) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def create_post(%Accounts.User{} = user, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a post.
  ## Examples
      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}
      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec update_post(User.t(), non_neg_integer() | String.t(), map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def update_post(current_user, post_id, attrs) do
    post = get_post!(current_user.id, post_id)

    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.
  ## Examples
      iex> delete_post(post)
      {:ok, %Post{}}
      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete_post(User.t(), non_neg_integer() | String.t()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def delete_post(current_user, id) do
    post = get_post!(current_user.id, id)
    Repo.delete(post)
  end

  ############# LIKES ###########################

  @doc """
  like someone's post: the post_id and current user should be passed
  current user will be assigned automatically with actions in like_controller
  """
  @spec create_like(User.t(), non_neg_integer() | String.t(), non_neg_integer() | String.t()) ::
          {:ok, Like.t()} | {:error, Ecto.Changeset.t(Like.t())}
  def create_like(%Accounts.User{} = user, author_id, post_id) do
    post = get_post!(author_id, post_id)

    %Like{}
    |> Like.changeset(%{user_id: user.id, post_id: post_id})
    |> Ecto.Changeset.put_assoc(:post, post)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  defp get_like_query(query, post_id, %Accounts.User{id: user_id}) do
    from l in query, where: l.post_id == ^post_id and l.user_id == ^user_id
  end

  @doc """
  unlike someone else's post, the post and current user should be passed
  raises EctoNoResults exception
  """
  @spec delete_like(User.t(), non_neg_integer() | String.t()) ::
          {:ok, Like.t()} | {:error, Ecto.Changeset.t(Like.t())}
  def delete_like(%Accounts.User{} = user, post_id) do
    Like
    |> get_like_query(post_id, user)
    |> Repo.one!()
    |> Repo.delete()
  end
end
