defmodule ToPdfWeb.SiteLive.FormComponent do
  use ToPdfWeb, :live_component

  alias ToPdf.Consumers

  @impl true
  def update(%{site: site} = assigns, socket) do
    changeset = Consumers.change_site(site)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"site" => site_params}, socket) do
    site_params = site_params
      |> Map.put("slug", Slug.slugify(Map.get(site_params, "name", "")))

    changeset =
      socket.assigns.site
      |> Consumers.change_site(site_params)
      |> Map.put(:action, :validate)

    socket = socket
      |> assign(:changeset, changeset)
      |> assign(:site, IO.inspect(Ecto.Changeset.apply_changes(changeset)))

    {:noreply, socket}
  end

  def handle_event("save", %{"site" => site_params}, socket) do
    save_site(socket, socket.assigns.action, site_params)
  end

  defp save_site(socket, :edit, site_params) do
    case Consumers.update_site(socket.assigns.site, site_params) do
      {:ok, _site} ->
        {:noreply,
         socket
         |> put_flash(:info, "Site updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_site(socket, :new, site_params) do
    case Consumers.create_site(site_params) do
      {:ok, _site} ->
        {:noreply,
         socket
         |> put_flash(:info, "Site created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
