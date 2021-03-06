defmodule ToPdf.Notifications.JobNotifier do
  import Swoosh.Email
  alias ToPdf.Mailer

  defp get_name_email(), do: {System.get_env("MAIL_FROM_NAME") |> String.trim(), System.get_env("MAIL_FROM_ADDRESS") |> String.trim()}
  defp make_job_url(id), do: "#{System.get_env("TOPDF_PUBLIC_URL") |> String.trim()}/download/#{id}"

  def deliver_success(%{name: name, email: email}, job_id) do
    new()
    |> to({name, email})
    |> from(get_name_email())
    |> subject("Votre PDF est prêt.")
#   |> html_body("<h1>Hello, #{name}</h1>")
    |> text_body("""
Bonjour, votre fichier PDF est prêt.
Vous pouvez le télécharger jusqu'à cinq fois à cette URL :
#{make_job_url(job_id)}
      """)
    |> Mailer.deliver_incremental()
  end

  def deliver_failure(%{name: _name, email: email}) do
    new()
    |> to([email, System.get_env("APP_DEVELOPER_EMAIL")])
    |> from(get_name_email())
    |> subject("La préparation du PDF a échoué")
#   |> html_body("<h1>Hello, #{name}</h1>")
    |> text_body("""
La conversion de votre document imprimable en PDF a échoué. Nous en sommes prévenus.
      """)
    |> Mailer.deliver_incremental()
  end

  def test_email() do
    new()
    |> to(get_name_email())
    |> from(get_name_email())
    |> subject("Email de test")
    |> text_body("Email de test")
    |> Mailer.deliver()
  end
end
