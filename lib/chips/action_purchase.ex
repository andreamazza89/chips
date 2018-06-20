defmodule Chips.ActionPurchase do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.ActionPurchase


  schema "action_purchases" do
    field :units_bought, :integer
    field :user_name, :string

    belongs_to(:action_sale, Chips.ActionSale)

    timestamps()
  end

  def changeset(%ActionPurchase{} = action_purchase, attrs) do
    action_purchase
    |> cast(attrs, [:action_sale_id, :units_bought, :user_name])
    |> validate_required([:action_sale_id, :units_bought, :user_name])
  end
end
