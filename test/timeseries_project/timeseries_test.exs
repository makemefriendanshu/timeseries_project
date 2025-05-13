defmodule TimeseriesProject.TimeseriesTest do
  use TimeseriesProject.DataCase

  alias TimeseriesProject.Timeseries

  describe "users" do
    alias TimeseriesProject.Timeseries.Stock

    import TimeseriesProject.TimeseriesFixtures

    @invalid_attrs %{symbol: nil, price: nil}

    test "list_users/0 returns all users" do
      stock = stock_fixture()
      assert Timeseries.list_users() == [stock]
    end

    test "get_stock!/1 returns the stock with given id" do
      stock = stock_fixture()
      assert Timeseries.get_stock!(stock.id) == stock
    end

    test "create_stock/1 with valid data creates a stock" do
      valid_attrs = %{symbol: "some symbol", price: 42}

      assert {:ok, %Stock{} = stock} = Timeseries.create_stock(valid_attrs)
      assert stock.symbol == "some symbol"
      assert stock.price == 42
    end

    test "create_stock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeseries.create_stock(@invalid_attrs)
    end

    test "update_stock/2 with valid data updates the stock" do
      stock = stock_fixture()
      update_attrs = %{symbol: "some updated symbol", price: 43}

      assert {:ok, %Stock{} = stock} = Timeseries.update_stock(stock, update_attrs)
      assert stock.symbol == "some updated symbol"
      assert stock.price == 43
    end

    test "update_stock/2 with invalid data returns error changeset" do
      stock = stock_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeseries.update_stock(stock, @invalid_attrs)
      assert stock == Timeseries.get_stock!(stock.id)
    end

    test "delete_stock/1 deletes the stock" do
      stock = stock_fixture()
      assert {:ok, %Stock{}} = Timeseries.delete_stock(stock)
      assert_raise Ecto.NoResultsError, fn -> Timeseries.get_stock!(stock.id) end
    end

    test "change_stock/1 returns a stock changeset" do
      stock = stock_fixture()
      assert %Ecto.Changeset{} = Timeseries.change_stock(stock)
    end
  end

  describe "stocks" do
    alias TimeseriesProject.Timeseries.Stock

    import TimeseriesProject.TimeseriesFixtures

    @invalid_attrs %{symbol: nil, price: nil}

    test "list_stocks/0 returns all stocks" do
      stock = stock_fixture()
      assert Timeseries.list_stocks() == [stock]
    end

    test "get_stock!/1 returns the stock with given id" do
      stock = stock_fixture()
      assert Timeseries.get_stock!(stock.id) == stock
    end

    test "create_stock/1 with valid data creates a stock" do
      valid_attrs = %{symbol: "some symbol", price: 42}

      assert {:ok, %Stock{} = stock} = Timeseries.create_stock(valid_attrs)
      assert stock.symbol == "some symbol"
      assert stock.price == 42
    end

    test "create_stock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeseries.create_stock(@invalid_attrs)
    end

    test "update_stock/2 with valid data updates the stock" do
      stock = stock_fixture()
      update_attrs = %{symbol: "some updated symbol", price: 43}

      assert {:ok, %Stock{} = stock} = Timeseries.update_stock(stock, update_attrs)
      assert stock.symbol == "some updated symbol"
      assert stock.price == 43
    end

    test "update_stock/2 with invalid data returns error changeset" do
      stock = stock_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeseries.update_stock(stock, @invalid_attrs)
      assert stock == Timeseries.get_stock!(stock.id)
    end

    test "delete_stock/1 deletes the stock" do
      stock = stock_fixture()
      assert {:ok, %Stock{}} = Timeseries.delete_stock(stock)
      assert_raise Ecto.NoResultsError, fn -> Timeseries.get_stock!(stock.id) end
    end

    test "change_stock/1 returns a stock changeset" do
      stock = stock_fixture()
      assert %Ecto.Changeset{} = Timeseries.change_stock(stock)
    end
  end
end
