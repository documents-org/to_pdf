defmodule ToPdf.Consumers.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :finished_at, :naive_datetime
    field :id_site, :integer
    field :params, :map
    field :started_at, :naive_datetime
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:id_site, :params, :status, :started_at, :finished_at])
    |> validate_required([:id_site, :params, :status, :started_at, :finished_at])
  end
end
