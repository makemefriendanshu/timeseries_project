defmodule TimeseriesProjectWeb.StockController do
  use TimeseriesProjectWeb, :controller

  alias TimeseriesProject.Timeseries
  alias TimeseriesProject.Timeseries.Stock

  def index(conn, _params) do
    stocks = Timeseries.list_stocks()
    render(conn, :index, stocks: stocks)
  end

  def new(conn, _params) do
    changeset = Timeseries.change_stock(%Stock{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"stock" => stock_params}) do
    case Timeseries.create_stock(stock_params) do
      {:ok, stock} ->
        conn
        |> put_flash(:info, "Stock created successfully.")
        |> redirect(to: ~p"/stocks/#{stock}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    stock = Timeseries.get_stock!(id)
    render(conn, :show, stock: stock)
  end

  def edit(conn, %{"id" => id}) do
    stock = Timeseries.get_stock!(id)
    changeset = Timeseries.change_stock(stock)
    render(conn, :edit, stock: stock, changeset: changeset)
  end

  def update(conn, %{"id" => id, "stock" => stock_params}) do
    stock = Timeseries.get_stock!(id)

    case Timeseries.update_stock(stock, stock_params) do
      {:ok, stock} ->
        conn
        |> put_flash(:info, "Stock updated successfully.")
        |> redirect(to: ~p"/stocks/#{stock}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, stock: stock, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    stock = Timeseries.get_stock!(id)
    {:ok, _stock} = Timeseries.delete_stock(stock)

    conn
    |> put_flash(:info, "Stock deleted successfully.")
    |> redirect(to: ~p"/stocks")
  end
end
