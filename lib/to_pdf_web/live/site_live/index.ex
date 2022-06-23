defmodule ToPdfWeb.SiteLive.Index do
  use ToPdfWeb, :live_view

  alias ToPdf.Consumers
  alias ToPdf.Consumers.Site
  @chars "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" |> String.split("")

  defp random_string(len) do
    Enum.map(1..len, fn _ -> Enum.random(@chars) end) |> Enum.join("")
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :sites, list_sites())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Site")
    |> assign(:site, Consumers.get_site!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Site")
    |> assign(:site, %Site{ token: random_string(180) })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sites")
    |> assign(:site, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    site = Consumers.get_site!(id)
    {:ok, _} = Consumers.delete_site(site)

    {:noreply, assign(socket, :sites, list_sites())}
  end

  defp list_sites do
    Consumers.list_sites()
  end
end
