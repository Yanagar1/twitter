defmodule Twitter.Twits.Like do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          user: User.t(),
          post: Post.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "likes" do
    belongs_to :user, Twitter.Accounts.User
    belongs_to :post, Twitter.Twits.Post

    timestamps()
  end

  @doc """
  validate that fields are non-empty when registering like
  """
  @spec changeset(t, map()) :: Ecto.Changeset.t(t)
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
  end
end
