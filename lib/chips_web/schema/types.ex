defmodule ChipsWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :tournament do
    field :id, :id
    field :city, :string
    field :name, :string
    field :starts, :naive_datetime

    field :users, list_of(:user)
  end

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string

    field :tournaments, list_of(:tournament)
  end

end
