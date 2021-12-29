defmodule TwitterWeb.BrowseControllerTest do
  use TwitterWeb.ConnCase
  alias Twitter.Twits
  # make post from one user account, then relogin -> should still
  # see the post, as it is the public post controller
  setup %{conn: conn} do
    author = user_fixture()
    reader = user_fixture()

    {:ok, post} = Twits.create_post(author, %{body: "i love you"})

    %{conn: conn, post: post, author: author, reader: reader}
  end

  test "index: lists all author's posts", %{conn: conn, author: author, reader: reader} do
    # reader logs in
    conn =
      conn
      |> init_test_session(current_user: reader, user_id: reader.id)
      |> get(Routes.browse_path(conn, :index, author.id))

    assert html_response(conn, 200) =~ "i love you"
  end

  test "index: failed logged in", %{conn: conn, author: author} do
    conn = get(conn, Routes.browse_path(conn, :index, author.id))
    assert redirected_to(conn) == Routes.page_path(conn, :index)
  end
end
