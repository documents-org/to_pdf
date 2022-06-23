defmodule ToPdf.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :id_site, :integer
      add :params, :map
      add :status, :string
      add :started_at, :naive_datetime
      add :finished_at, :naive_datetime

      timestamps()
    end
  end
end
