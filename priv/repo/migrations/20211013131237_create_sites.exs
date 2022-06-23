defmodule ToPdf.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string
      add :slug, :string
      add :token, :string

      timestamps()
    end
  end
end
