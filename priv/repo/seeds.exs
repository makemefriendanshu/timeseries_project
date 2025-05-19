# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TimeseriesProject.Repo.insert!(%TimeseriesProject.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TimeseriesProject.Repo
alias TimeseriesProject.Timeseries.Stock

{_, sd, _} = DateTime.from_iso8601("2025-05-01T23:50:07Z")
{_, ed, _} = DateTime.from_iso8601("2025-07-01T23:50:07Z")
{sd, ed} = {sd |> DateTime.to_unix(), ed |> DateTime.to_unix()}

1..100
|> Enum.map(fn _n ->
  %Stock{}
  |> Stock.changeset(%{
    price: "#{Enum.random(1..1_000)}.#{Enum.random(1..1_00)}",
    symbol: Enum.random(["AAPL", "MSFT"]),
    timestamp: "#{Enum.random(sd..ed)}"
  })
  |> Repo.insert()
end)

tsv =
  Repo.all(Stock)
  |> Enum.map(fn s -> %{symbol: s.symbol, timestamp: s.timestamp, price: s.price} end)
  |> CSV.encode(headers: true, separator: ?\t, delimiter: "\n")
  |> Enum.to_list()

File.write("./new.tsv", tsv)

tsv_list =
  1..100
  |> Enum.map(fn _n ->
    %{
      symbol: Enum.random(["AAPL", "MSFT", "GOOGL"]),
      timestamp: "#{Enum.random(sd..ed)}",
      price: "#{Enum.random(1..1_000)}.#{Enum.random(1..1_00)}"
    }
  end)
  |> CSV.encode(headers: true, separator: ?\t, delimiter: "\n")
  |> Enum.to_list()

file_name = "./new-#{Enum.random(1..1_00)}.tsv"
File.write(file_name, tsv_list)

file_name
|> Path.expand(__DIR__)
|> File.stream!()
|> CSV.decode!(headers: true, separator: ?\t, delimiter: "\n")
|> Enum.to_list()
|> Enum.map(fn n ->
  %Stock{}
  |> Stock.changeset(n)
  |> Repo.insert()
end)
