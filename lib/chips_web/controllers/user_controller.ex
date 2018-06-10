defmodule ChipsWeb.UserController do
  use ChipsWeb, :controller

  def create(conn, user_parameters) do
    case Chips.DataStore.add_user(user_parameters) do
      {:ok, user} ->
        conn
        |> put_status(200)
        |> json(authenticated_user_response_body(user))

      {:error, _changeset} ->
        conn
        |> resp(400, "failed to create user")
    end
  end

  defp authenticated_user_response_body(user) do
    %{
      email: user.email,
      token: ChipsWeb.Guardian.token_for_user(user),
      user_name: user.user_name
    }
  end

  def login(conn, %{"password" => password, "user_name" => user_name}) do
    case Chips.DataStore.find_user(user_name) do
      nil ->
        Pbkdf2.no_user_verify()
        resp(conn, 400, "user not found or wrong password")

      user ->
        if Pbkdf2.verify_pass(password, user.password) do
          conn
          |> put_status(200)
          |> json(%{
            email: user.email,
            token: ChipsWeb.Guardian.token_for_user(user),
            user_name: user.user_name
          })
        else
          resp(conn, 400, "user not found or wrong password")
        end
    end
  end
end
