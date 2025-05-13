defmodule TimeseriesProject.Repo do
  use Ecto.Repo,
    otp_app: :timeseries_project,
    adapter: Ecto.Adapters.Postgres
end
