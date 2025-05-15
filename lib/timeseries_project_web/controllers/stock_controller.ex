defmodule TimeseriesProjectWeb.StockController do
  use TimeseriesProjectWeb, :controller

  alias TimeseriesProject.Timeseries
  alias TimeseriesProject.Timeseries.Stock

  alias TimeseriesProject.Repo

  def home(conn, _params) do
    symbols = Repo.all(Stock) |> Enum.map(fn x -> x.symbol end) |> Enum.uniq()
    time_axis = ["Hourly", "Daily"]
    render(conn, :home, symbols: symbols, time_axis: time_axis)
  end

  def get_data(conn, %{"symbol" => symbol, "time" => "Daily"} = _params) do
    timestamp =
      Repo.all(Stock)
      |> Enum.filter(&(&1.symbol == symbol))
      |> Enum.map(
        &%{
          "timestamp" =>
            &1.timestamp |> String.to_integer() |> DateTime.from_unix!() |> DateTime.to_date(),
          "price" => &1.price
        }
      )
      |> Enum.sort_by(& &1["timestamp"], {:asc, Date})

    conn
    |> json(timestamp)
  end

  def get_data(conn, %{"symbol" => symbol, "time" => "Hourly"} = _params) do
    timestamp =
      Repo.all(Stock)
      |> Enum.filter(&(&1.symbol == symbol))
      |> Enum.map(
        &%{
          "timestamp" =>
            &1.timestamp |> String.to_integer() |> DateTime.from_unix!() |> DateTime.to_time(),
          "price" => &1.price
        }
      )
      |> Enum.sort_by(& &1["timestamp"], {:asc, Time})

    conn
    |> json(timestamp)
  end

  def get_data(conn, %{"file" => file} = _params) do
    if file.content_type == "text/tab-separated-values" do
      Stock
      |> Repo.delete_all()
      |> IO.inspect(label: "label")

      file.path
      |> Path.expand(__DIR__)
      |> File.stream!()
      |> CSV.decode!(headers: true, separator: ?\t, delimiter: "\n")
      |> Enum.to_list()
      |> Enum.map(fn n ->
        %Stock{}
        |> Stock.changeset(n)
        |> Repo.insert()
      end)

      conn
      |> json(%{success: "Success. File upload is completed."})
    else
      conn
      |> json(%{failure: "Failure. Please provide TSV file."})
    end
  end

  def get_data(
        conn,
        %{
          "action" => "download",
          "enddate" => enddate,
          "startdate" => startdate,
          "stock" => stock
        } = _params
      ) do
    startdate =
      if(startdate == "") do
        Date.utc_today() |> Date.to_string
      end

    enddate =
      if(enddate == "") do
        Date.utc_today() |> Date.to_string
      end

    {_, sd, _} = DateTime.from_iso8601(startdate <> "T23:50:07Z")
    {_, ed, _} = DateTime.from_iso8601(enddate <> "T23:50:07Z")
    {sd, ed} = {sd |> DateTime.to_unix(), ed |> DateTime.to_unix()}

    content =
      1..100
      |> Enum.map(fn _n ->
        %{
          symbol: Enum.random(stock),
          timestamp: "#{Enum.random(sd..ed)}",
          price: "#{Enum.random(1..1_000)}.#{Enum.random(1..1_00)}"
        }
      end)
      |> CSV.encode(headers: true, separator: ?\t, delimiter: "\n")
      |> Enum.to_list()

    file =
      %{
        name: "./new-#{Enum.random(1..1_00)}.tsv",
        type: "text/tab-separated-values",
        data: content
      }

    conn
    |> json(%{file: file})
  end

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
