defmodule ChipsWeb.Router do
  use ChipsWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticate do
    plug(
      Guardian.Plug.Pipeline,
      error_handler: ChipsWeb.Guardian,
      module: ChipsWeb.Guardian
    )

    plug(Guardian.Plug.VerifyHeader, realm: "Token")
    plug(Guardian.Plug.LoadResource)
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(ChipsWeb.AddUserToAbsintheContext)
  end

  scope "/" do
    pipe_through(:browser)

    get("/", ChipsWeb.PageController, :index)
  end

  scope "/api" do
    pipe_through(:api)

    post("/users", ChipsWeb.UserController, :create)
    get("/users/:user_name", ChipsWeb.UserController, :login)

    pipe_through(:authenticate)

    forward("/", Absinthe.Plug, schema: ChipsWeb.Schema)
    forward("/graphiql", Absinthe.Plug.GraphiQL, schema: ChipsWeb.Schema)
  end
end
