defmodule MobileMarkdownWeb.CredentialView do
  use MobileMarkdownWeb, :view
  alias MobileMarkdownWeb.CredentialView

  def render("index.json", %{credential: credential}) do
    %{data: render_one(credential, CredentialView, "credential.json")}
  end

  def render("credential.json", %{credential: credential}), do: credential
end
