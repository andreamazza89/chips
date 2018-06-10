defmodule Chips.DataStore do
  alias Chips.{Repo, User}
  import Ecto.Query

  def add_user(user_data) do
    User.changeset(user_data)
    |> Repo.insert()
  end

  def find_user(user_name) do
    Repo.one(
      from(
        u in User,
        select: u,
        where: u.user_name == ^user_name
      )
    )
  end
end
