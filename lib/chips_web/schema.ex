defmodule ChipsWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Type.Custom
  import_types ChipsWeb.Schema.Types

  alias ChipsWeb.Resolvers

  query do

     field :tournaments, list_of(:tournament) do
       resolve &Resolvers.Data.list_tournaments/3
     end

  end


	mutation do

		field :create_tournament, type: :tournament do
			arg :city, non_null(:string)
			arg :name, non_null(:string)
			arg :starts, :naive_datetime

			resolve &Resolvers.Data.create_tournament/3
		end

	end

end
