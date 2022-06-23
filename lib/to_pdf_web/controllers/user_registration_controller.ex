defmodule ToPdfWeb.UserRegistrationController do
  use ToPdfWeb, :controller

  alias ToPdf.Accounts
  alias ToPdf.Accounts.User
  alias ToPdfWeb.UserAuth

  def new(conn, _params) do
    if !ToPdf.Accounts.has_at_least_one_user? do
      changeset = Accounts.change_user_registration(%User{})
      render(conn, "new.html", changeset: changeset)
    else 
      render(conn, "registration_disabled.html")
    end
  end

  def create(conn, %{"user" => user_params}) do
    if !ToPdf.Accounts.has_at_least_one_user? do
      case Accounts.register_user(user_params) do
        {:ok, user} ->
          {:ok, _} =
            Accounts.deliver_user_confirmation_instructions(
              user,
              &Routes.user_confirmation_url(conn, :edit, &1)
            )

          conn
          |> put_flash(:info, "User created successfully.")
          |> UserAuth.log_in_user(user)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn |> redirect(to: "/users/register")
    end
  end
end
