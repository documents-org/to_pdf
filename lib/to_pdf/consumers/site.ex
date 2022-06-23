defmodule ToPdf.Consumers.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :name, :string
    field :slug, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name, :slug, :token])
    |> validate_required([:name, :slug, :token])
  end
end
