defmodule TimeseriesProject.Repo.Migrations.CreateStocks do
  use Ecto.Migration

  def change do
    create table(:stocks) do
      add :symbol, :string
      add :timestamp, :string
      add :price, :string

      timestamps()
    end
  end
end
