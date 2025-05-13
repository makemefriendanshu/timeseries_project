defmodule TimeseriesProject.TimeseriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TimeseriesProject.Timeseries` context.
  """

  @doc """
  Generate a stock.
  """
  def stock_fixture(attrs \\ %{}) do
    {:ok, stock} =
      attrs
      |> Enum.into(%{
        price: 42,
        symbol: "some symbol"
      })
      |> TimeseriesProject.Timeseries.create_stock()

    stock
  end
end
