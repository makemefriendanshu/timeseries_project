defmodule TimeseriesProject.Timeseries.Stock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stocks" do
    field :symbol, :string
    field :timestamp, :string
    field :price, :string

    timestamps()
  end

  @doc false
  def changeset(stock, attrs) do
    stock
    |> cast(attrs, [:symbol, :price, :timestamp])
    |> validate_required([:symbol, :price, :timestamp])
  end
end
