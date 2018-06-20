defmodule Chips.ActionSaleResult do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.ActionSaleResult


  schema "results" do
    field :result, :integer

    belongs_to :action_sale, Chips.ActionSale
  end

  def changeset(%ActionSaleResult{} = result, attrs) do
    result
    |> cast(attrs, [:result, :action_sale_id])
    |> validate_required([:result, :action_sale_id])
  end
end
