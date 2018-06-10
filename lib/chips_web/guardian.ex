defmodule ChipsWeb.Guardian do
  use Guardian, otp_app: :chips
  use ChipsWeb, :controller

  alias Chips.{Repo, User}

  def subject_for_token(%User{} = user, _claims), do: {:ok, to_string(user.id)}
  def subject_for_token(_, _), do: {:error, "Unknown resource type"}

  def resource_from_claims(%{"sub" => user_id}), do: {:ok, Repo.get(User, user_id)}
  def resource_from_claims(_claims), do: {:error, "Unknown resource type"}

  def auth_error(conn, {_type, _reason}, _opts) do
    resp(conn, 400, "failed to authenticate")
  end

  def token_for_user(user) do
    {:ok, jwt, _full_claims} =
      ChipsWeb.Guardian.encode_and_sign(
        user,
        %{},
        token_type: :token
      )

    jwt
  end
end
