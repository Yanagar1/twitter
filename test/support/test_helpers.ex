defmodule Twitter.TestHelpers do
  alias Twitter.{
    Accounts
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "Some User",
        username: "user#{System.unique_integer([:positive])}",
        password: attrs[:password] || "supersecret",
        email: "email"
      })
      |> Accounts.create_user()

    user
  end
end
