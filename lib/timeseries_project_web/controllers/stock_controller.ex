defmodule TimeseriesProjectWeb.StockController do
  use TimeseriesProjectWeb, :controller

  alias TimeseriesProject.Timeseries
  alias TimeseriesProject.Timeseries.Stock
  alias TimeseriesProject.Repo

  def home(conn, _params) do
    stocks = Repo.all(Stock)
    symbols = stocks |> Enum.map(fn x -> x.symbol end) |> Enum.uniq() |> Enum.sort()
    time_axis = ["Daily", "Hourly"]

    dates =
      stocks
      |> Enum.map(fn x ->
        x.timestamp |> String.to_integer() |> DateTime.from_unix!() |> DateTime.to_date()
      end)
      |> Enum.uniq()

    render(conn, :home, symbols: symbols, time_axis: time_axis, dates: dates)
  end

  def get_data(conn, %{"action" => "get_graph", "symbol" => symbol, "time" => "Daily"} = _params) do
    stocks = Repo.all(Stock)

    timestamps =
      stocks
      |> Enum.filter(&(&1.symbol == symbol))
      |> Enum.map(
        &%{
          "timestamp" =>
            &1.timestamp |> String.to_integer() |> DateTime.from_unix!() |> DateTime.to_date(),
          "price" => &1.price
        }
      )
      |> Enum.sort_by(& &1["timestamp"], {:asc, Date})

    uniq_timestamps = timestamps |> Enum.uniq_by(& &1["timestamp"]) |> Enum.map(& &1["timestamp"])

    chunk_timestamps =
      uniq_timestamps
      |> Enum.map(fn x -> Enum.filter(timestamps, &(&1["timestamp"] == x)) end)

    chunk_sum =
      chunk_timestamps
      |> Enum.map(
        &(&1
          |> Enum.reduce({0, 0}, fn %{"price" => p, "timestamp" => _}, {sum, count} ->
            {sum + (p |> String.to_float()), count + 1}
          end))
      )
      |> Enum.with_index()

    timestamps =
      chunk_sum
      |> Enum.reduce([], fn {{sum, count}, v}, a ->
        a ++
          [
            %{
              "price" => sum / count,
              "timestamp" => Enum.at(uniq_timestamps, v)
            }
          ]
      end)

    conn
    |> json(%{timestamps: timestamps})
  end

  def get_data(
        conn,
        %{"action" => "get_graph", "symbol" => symbol, "time" => "Hourly", "date" => date} =
          _params
      ) do
    stocks = Repo.all(Stock)

    timestamps =
      stocks
      |> Enum.filter(
        &(&1.symbol == symbol &&
            &1.timestamp
            |> String.to_integer()
            |> DateTime.from_unix!()
            |> DateTime.to_date()
            |> Date.to_string() ==
              date)
      )
      |> Enum.map(
        &%{
          "timestamp" =>
            &1.timestamp |> String.to_integer() |> DateTime.from_unix!() |> DateTime.to_time(),
          "price" => &1.price
        }
      )
      |> Enum.sort_by(& &1["timestamp"], {:asc, Time})

    uniq_timestamps = timestamps |> Enum.uniq_by(& &1["timestamp"]) |> Enum.map(& &1["timestamp"])

    chunk_timestamps =
      uniq_timestamps |> Enum.map(fn x -> Enum.filter(timestamps, &(&1["timestamp"] == x)) end)

    chunk_sum =
      chunk_timestamps
      |> Enum.map(
        &(&1
          |> Enum.reduce({0, 0}, fn %{"price" => p, "timestamp" => _}, {sum, count} ->
            {sum + (p |> String.to_float()), count + 1}
          end))
      )
      |> Enum.with_index()

    timestamps =
      chunk_sum
      |> Enum.reduce([], fn {{sum, count}, v}, a ->
        a ++
          [
            %{
              "price" => sum / count,
              "timestamp" => Enum.at(uniq_timestamps, v)
            }
          ]
      end)

    conn
    |> json(%{timestamps: timestamps})
  end

  def get_data(conn, %{"action" => "file_upload", "file" => file} = _params) do
    if file.content_type == "text/tab-separated-values" do
      Stock
      |> Repo.delete_all()

      list =
        file.path
        |> Path.expand(__DIR__)
        |> File.stream!()
        |> CSV.decode!(headers: true, separator: ?\t, delimiter: "\n")
        |> Enum.to_list()
        |> Enum.map(fn x ->
          %{
            price: x["price"],
            symbol: x["symbol"],
            timestamp: x["timestamp"],
            inserted_at: NaiveDateTime.local_now(),
            updated_at: NaiveDateTime.local_now()
          }
        end)

      Repo.insert_all(Stock, list)
      stocks = Repo.all(Stock)

      symbols =
        stocks
        |> Enum.map(fn x -> x.symbol end)
        |> Enum.uniq()
        |> Enum.sort()

      dates =
        stocks
        |> Enum.map(fn x ->
          x.timestamp |> String.to_integer() |> DateTime.from_unix!() |> DateTime.to_date()
        end)
        |> Enum.uniq()
        |> Enum.sort()

      conn
      |> json(%{success: "Success. File upload is completed.", symbols: symbols, dates: dates})
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
          "symbol" => symbol
        } = _params
      ) do
    startdate =
      if startdate == "", do: Date.utc_today() |> Date.to_string(), else: startdate

    enddate =
      if enddate == "", do: Date.utc_today() |> Date.to_string(), else: enddate

    symbol =
      if symbol == "", do: ["AAPL", "MSFT", "GOOGL"], else: symbol

    {_, sd, _} =
      DateTime.from_iso8601(
        startdate <>
          "T#{Enum.random(0..23) |> append_zero}:#{Enum.random(0..59) |> append_zero}:#{Enum.random(0..59) |> append_zero}Z"
      )

    {_, ed, _} =
      DateTime.from_iso8601(
        enddate <>
          "T#{Enum.random(0..23) |> append_zero}:#{Enum.random(0..59) |> append_zero}:#{Enum.random(0..59) |> append_zero}Z"
      )

    {sd, ed} =
      if DateTime.compare(sd, ed) == :lt,
        do: {sd |> DateTime.to_unix(), ed |> DateTime.to_unix()},
        else: {ed |> DateTime.to_unix(), sd |> DateTime.to_unix()}

    content =
      1..100
      |> Enum.map(fn _n ->
        %{
          symbol: Enum.random(symbol),
          timestamp: "#{Enum.random(sd..ed)}",
          price: "#{Enum.random(1..1_000)}.#{Enum.random(1..1_00)}"
        }
      end)
      |> CSV.encode(headers: true, separator: ?\t, delimiter: "\n")
      |> Enum.to_list()

    file =
      %{
        name: "new-#{Enum.random(1..1_00)}.tsv",
        type: "text/tab-separated-values",
        data: content
      }

    conn
    |> json(%{file: file})
  end

  def append_zero(num) do
    if num < 10, do: "0#{num}", else: "#{num}"
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
