defmodule ToPdf.Mailer do
  use Swoosh.Mailer, otp_app: :to_pdf

  @interval 5000

  def deliver_incremental(email) do
    do_deliver_incremental(email, 0)
  end

  def do_deliver_incremental(email, 6) do
    import Swoosh.Email

    new()
    |> to(System.get_env("APP_DEVELOPER_EMAIL"))
    |> from(System.get_env("MAIL_FROM_ADDRESS"))
    |> subject("Un envoi d'email via l'API a échoué plus de cinq fois.")
    |> text_body("""
         Détails : 

        #{:erlang.term_to_binary(email)}
      """)
    |> deliver_incremental()
  end

  def do_deliver_incremental(email, n) do
    case deliver(email) do
      {:ok, _} -> :ok
      _ -> 
        :timer.sleep(n * @interval)
        do_deliver_incremental(email, n + 1)
    end
  end
end
