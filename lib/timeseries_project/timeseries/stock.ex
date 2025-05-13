defmodule TimeseriesProject.Timeseries.Stock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :symbol, :string
    field :price, :integer

    timestamps()
  end

  @doc false
  def changeset(stock, attrs) do
    stock
    |> cast(attrs, [:symbol, :price])
    |> validate_required([:symbol, :price])
  end
end
