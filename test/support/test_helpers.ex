defmodule Twitter.TestHelpers do
  alias Twitter.{
    Accounts
  }

  alias Twitter.{
    Twits
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "Some User",
        username: "user#{System.unique_integer([:positive])}",
        password: attrs[:password] || "supersecret",
        email: "email#{System.unique_integer([:positive])}"
      })
      |> Accounts.create_user()

    user
  end

  def post_fixture(user, attrs \\ %{body: "some body"}) do
    {:ok, post} = Twits.create_post(user, attrs)
    post
  end
end
