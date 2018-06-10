defmodule Chips.UserControllerTest do
  use ChipsWeb.ConnCase

  @test_user %{email: "asdf@b.c", password: "pss", user_name: "Gigi"}

  test "creating a user gives out a token and user info", %{conn: conn} do
    %{"token" => _token} =
      perform_create_user_request(conn, @test_user)
      |> json_response(200)
  end

  test "creating a user has required fields", %{conn: conn} do
    [
      %{user_name: "l", password: "pss"},
      %{email: "a@b.c", password: "pss"},
      %{email: "a@b.c", user_name: "pss"}
    ]
    |> Enum.each(fn user_info ->
      perform_create_user_request(conn, user_info)
      |> response(400)
    end)
  end

  test "logging in a user gives out a token and user info", %{conn: conn} do
    perform_create_user_request(conn, @test_user)

    %{
      "token" => _token,
      "email" => email,
      "user_name" => user_name
    } =
      conn
      |> get("/api/users/" <> @test_user.user_name <> "?password=" <> @test_user.password)
      |> json_response(200)

    assert email == @test_user.email
    assert user_name == @test_user.user_name
  end

  test "cannot login inexistent user", %{conn: conn} do
    conn
    |> get("/api/users/lol?password=pss")
    |> response(400)
  end

  test "cannot login with wrong password", %{conn: conn} do
    perform_create_user_request(conn, @test_user)

    conn
    |> get("/api/users/" <> @test_user.user_name <> "?password=asdf")
    |> response(400)
  end

  test "the token can be used to query protected routes", %{conn: conn} do
    %{"token" => token} =
      perform_create_user_request(conn, @test_user)
      |> json_response(200)

    conn
    |> put_req_header("authorization", "Token " <> token)
    |> post("/api", %{query: "query { tournaments { id } }"})
    |> json_response(200)
  end

  test "protected routes cannot be accessed without the token", %{conn: conn} do
    conn
    |> post("/api", %{query: "query { tournaments { id } }"})
    |> response(400)
  end

  defp perform_create_user_request(conn, user_info) do
    conn
    |> post("/api/users", user_info)
  end
end
