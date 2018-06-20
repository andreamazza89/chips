defmodule Chips.ActionSale do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.ActionSale


  schema "action_sales" do
    field :markup, :float
    field :result, :integer
    field :units_on_sale, :integer
    field :user_name, :string

    belongs_to(:tournament, Chips.Tournament)
    has_many(:action_purchases, Chips.ActionPurchase)

    timestamps()
  end

  def changeset(%ActionSale{} = action_sale, attrs) do
    action_sale
    |> cast(attrs, [:result, :units_on_sale, :markup, :user_name, :tournament_id])
    |> validate_required([:units_on_sale, :markup, :user_name, :tournament_id])
  end

  def add_result(%ActionSale{} = action_sale, %{action_sale_result: result}) do
    action_sale
    |> cast(%{result: result}, [:result])
  end
end
