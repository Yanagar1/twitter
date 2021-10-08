defmodule Twitter.Accounts do
  @moduledoc """
  The Accounts context.
  """
  alias Twitter.Repo
  alias Twitter.Accounts.User

  @spec create_user(map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t(User.t())}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec get_user(integer() | String.t()) :: User.t() | nil
  def get_user(id) do
    Repo.get(User, id)
  end

  @spec get_user!(integer() | String.t()) :: User.t()
  # has error handling
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @spec get_user_by(map()) :: User.t() | nil
  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  @spec list_users :: list(User.t())
  def list_users do
    Repo.all(User)
  end

  @spec change_user(User.t()) :: Ecto.Changeset.t(User.t())
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @spec authenticate_by_username_and_pass(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, :unauthorized | :not_found}

  def authenticate_by_username_and_pass(username, given_pass) do
    user = get_user_by(username: username)

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
