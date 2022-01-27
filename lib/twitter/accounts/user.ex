defmodule Twitter.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          username: String.t(),
          email: String.t(),
          password: String.t(),
          password_hash: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          id: non_neg_integer()
        }
  schema "users" do
    field :name, :string
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc """
  validate data on registration, includes the call to the regular changeset
  """
  @spec registration_changeset(t, map()) :: Ecto.Changeset.t(t)
  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  @doc """
  the regular changeset, validation for non-password inputs
  """
  @spec changeset(t, map()) :: Ecto.Changeset.t(t)
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :email])
    |> validate_required([:name, :username, :email])
    |> validate_length(:username, min: 1, max: 25)
    |> unique_constraint([:username])
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: pass}}) do
    put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(pass))
  end
  
  defp put_pass_hash(changeset) do
    changeset
  end
end
