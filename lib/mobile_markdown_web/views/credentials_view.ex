defmodule MobileMarkdownWeb.CredentialsView do
  use MobileMarkdownWeb, :view

  def render("credentials.json", assigns) do
    %{
      host: assigns.host,
      credential: assigns.credential_string,
      date: assigns.date,
      policy: assigns.policy,
      signature: assigns.signature
    }
  end
end
