defmodule Twitter.Accounts do
  @moduledoc """
  The Accounts context.
  """
  alias Twitter.Repo
  alias Twitter.Accounts.User

  @doc """
  create user: validate parameters and insert in the db
  """
  @spec create_user(map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t(User.t())}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  get_user: returns user by id
  """
  @spec get_user(non_neg_integer() | String.t()) :: User.t() | nil
  def get_user(id) do
    Repo.get(User, id)
  end

  @doc """
  returns user by id or raises Ecto.NoResultsError if not found
  """
  @spec get_user!(non_neg_integer() | String.t()) :: User.t()
  # has error handling
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @doc """
  lists all users in db
  """
  @spec list_users :: list(User.t())
  def list_users do
    Repo.all(User)
  end

  @doc """
  find user by username, compare input password to the stored one.
  returns {:ok, user} on success, {:error, :errorcode} on failure
  """
  @spec authenticate_by_username_and_pass(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, :unauthorized | :not_found}

  def authenticate_by_username_and_pass(username, given_pass) do
    user = Repo.get_by(User, username: username)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
