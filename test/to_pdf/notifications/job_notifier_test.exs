defmodule ToPdf.Notifications.JobNotifierTest do
  use ExUnit.Case, async: true
  import Swoosh.TestAssertions

  alias ToPdf.Notifications.JobNotifier

  test "deliver_success/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    JobNotifier.deliver_success(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end

  test "deliver_failure/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    JobNotifier.deliver_failure(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end
end
