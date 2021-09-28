defmodule ToPdfWeb.Notifier do

	def notify_success(email, filename) do
		{:ok, link_id} = ToPdfWeb.DownloadAgent.register_download_link(filename)
		ToPdf.Notifications.JobNotifier.deliver_success(%{name: "", email: email}, link_id)
	end

	def notify_failure(email) do
		ToPdf.Notifications.JobNotifier.deliver_failure(%{name: "", email: email})
	end
end