defmodule Twitter.Twits.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          body: String.t(),
          user: User.t(),
          likes: list(Like.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }
  schema "posts" do
    field :body, :string
    has_many :likes, Twitter.Twits.Like
    belongs_to :user, Twitter.Accounts.User

    timestamps()
  end

  @doc """
  validate for non-empty text
  """
  @spec changeset(t, map()) :: Ecto.Changeset.t(t)
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 1, max: 700)
  end
end
