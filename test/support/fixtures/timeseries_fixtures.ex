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
        price: "117.452",
        symbol: "some symbol",
        timestamp: "1601551744"
      })
      |> TimeseriesProject.Timeseries.create_stock()

    stock
  end
end
