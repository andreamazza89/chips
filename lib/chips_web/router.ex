defmodule ChipsWeb.Router do
  use ChipsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

		get "/", ChipsWeb.PageController, :index
	end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: ChipsWeb.Schema

    forward "/", Absinthe.Plug,
      schema: ChipsWeb.Schema
  end

end
