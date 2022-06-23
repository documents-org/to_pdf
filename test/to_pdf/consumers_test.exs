defmodule ToPdf.ConsumersTest do
  use ToPdf.DataCase

  alias ToPdf.Consumers

  describe "sites" do
    alias ToPdf.Consumers.Site

    import ToPdf.ConsumersFixtures

    @invalid_attrs %{name: nil, slug: nil, token: nil}

    test "list_sites/0 returns all sites" do
      site = site_fixture()
      assert Consumers.list_sites() == [site]
    end

    test "get_site!/1 returns the site with given id" do
      site = site_fixture()
      assert Consumers.get_site!(site.id) == site
    end

    test "create_site/1 with valid data creates a site" do
      valid_attrs = %{name: "some name", slug: "some slug", token: "some token"}

      assert {:ok, %Site{} = site} = Consumers.create_site(valid_attrs)
      assert site.name == "some name"
      assert site.slug == "some slug"
      assert site.token == "some token"
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Consumers.create_site(@invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      update_attrs = %{name: "some updated name", slug: "some updated slug", token: "some updated token"}

      assert {:ok, %Site{} = site} = Consumers.update_site(site, update_attrs)
      assert site.name == "some updated name"
      assert site.slug == "some updated slug"
      assert site.token == "some updated token"
    end

    test "update_site/2 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Consumers.update_site(site, @invalid_attrs)
      assert site == Consumers.get_site!(site.id)
    end

    test "delete_site/1 deletes the site" do
      site = site_fixture()
      assert {:ok, %Site{}} = Consumers.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> Consumers.get_site!(site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = Consumers.change_site(site)
    end
  end

  describe "jobs" do
    alias ToPdf.Consumers.Job

    import ToPdf.ConsumersFixtures

    @invalid_attrs %{finished_at: nil, id_site: nil, params: nil, started_at: nil, status: nil}

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Consumers.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Consumers.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      valid_attrs = %{finished_at: ~N[2021-10-12 13:13:00], id_site: 42, params: %{}, started_at: ~N[2021-10-12 13:13:00], status: "some status"}

      assert {:ok, %Job{} = job} = Consumers.create_job(valid_attrs)
      assert job.finished_at == ~N[2021-10-12 13:13:00]
      assert job.id_site == 42
      assert job.params == %{}
      assert job.started_at == ~N[2021-10-12 13:13:00]
      assert job.status == "some status"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Consumers.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      update_attrs = %{finished_at: ~N[2021-10-13 13:13:00], id_site: 43, params: %{}, started_at: ~N[2021-10-13 13:13:00], status: "some updated status"}

      assert {:ok, %Job{} = job} = Consumers.update_job(job, update_attrs)
      assert job.finished_at == ~N[2021-10-13 13:13:00]
      assert job.id_site == 43
      assert job.params == %{}
      assert job.started_at == ~N[2021-10-13 13:13:00]
      assert job.status == "some updated status"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Consumers.update_job(job, @invalid_attrs)
      assert job == Consumers.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Consumers.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Consumers.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Consumers.change_job(job)
    end
  end
end
