defmodule ToPdfWeb.JobLive.Index do
  use ToPdfWeb, :live_view

  alias ToPdf.Consumers
  alias ToPdf.Consumers.Job

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :jobs, list_jobs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Job")
    |> assign(:job, Consumers.get_job!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Job")
    |> assign(:job, %Job{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Jobs")
    |> assign(:job, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    job = Consumers.get_job!(id)
    {:ok, _} = Consumers.delete_job(job)

    {:noreply, assign(socket, :jobs, list_jobs())}
  end

  defp list_jobs do
    Consumers.list_jobs()
  end
end
