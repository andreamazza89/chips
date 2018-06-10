defmodule ChipsWeb.UserController do
  use ChipsWeb, :controller
  alias Chips.{Repo, User}
  import Ecto.Changeset
  import Ecto.Query

  def create(conn, user_parameters) do
    case User.changeset(%User{}, user_parameters)
         |> hash_password
         |> Repo.insert() do
      {:ok, user} ->
        {:ok, jwt, _full_claims} =
          user |> ChipsWeb.Guardian.encode_and_sign(%{}, token_type: :token)

        conn
        |> put_status(200)
        |> json(%{token: jwt, email: user.email, user_name: user.user_name})

      {:error, changeset} ->
        resp(conn, 400, "failed to create user")
    end
  end

  def login(conn, %{"password" => password, "user_name" => user_name}) do
    find_user_query =
      from(
        u in User,
        select: u,
        where: u.user_name == ^user_name
      )

    case Repo.one(find_user_query) do
      nil ->
        Pbkdf2.no_user_verify()
        resp(conn, 400, "user not found or wrong password")
      user ->
        if Pbkdf2.verify_pass(password, user.password) do
        {:ok, jwt, _full_claims} =
          user |> ChipsWeb.Guardian.encode_and_sign(%{}, token_type: :token)

          conn
          |> put_status(200)
          |> json(%{token: jwt, email: user.email, user_name: user.user_name})
        else
          resp(conn, 400, "user not found or wrong password")
        end
    end
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password, Pbkdf2.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end
end
