defmodule ChipsWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :tournament do
    field :id, :id
    field :city, :string
    field :name, :string
    field :starts, :naive_datetime
  end

end
