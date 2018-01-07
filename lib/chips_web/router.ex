defmodule ChipsWeb.Router do
  use ChipsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: ChipsWeb.Schema

    forward "/", Absinthe.Plug,
      schema: ChipsWeb.Schema
  end

end
