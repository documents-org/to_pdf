defmodule ToPdf.ConsumersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ToPdf.Consumers` context.
  """

  @doc """
  Generate a site.
  """
  def site_fixture(attrs \\ %{}) do
    {:ok, site} =
      attrs
      |> Enum.into(%{
        name: "some name",
        slug: "some slug",
        token: "some token"
      })
      |> ToPdf.Consumers.create_site()

    site
  end

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        finished_at: ~N[2021-10-12 13:13:00],
        id_site: 42,
        params: %{},
        started_at: ~N[2021-10-12 13:13:00],
        status: "some status"
      })
      |> ToPdf.Consumers.create_job()

    job
  end
end
