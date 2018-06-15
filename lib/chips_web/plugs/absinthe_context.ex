defmodule ChipsWeb.AddUserToAbsintheContext do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, options) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> resp(400, "request is missing token or token is invalid")

      user ->
        Absinthe.Plug.put_options(conn, context: %{user: user})
    end
  end
end
