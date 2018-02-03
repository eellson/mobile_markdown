defmodule MobileMarkdownWeb.CredentialController do
  use MobileMarkdownWeb, :controller

  alias MobileMarkdown.AWSSigV4

  action_fallback(MobileMarkdownWeb.FallbackController)

  @current_time_interface Application.get_env(:mobile_markdown, :current_time_interface)

  def index(conn, _params) do
    credential = AWSSigV4.get_credential(url(conn), now(), :s3, :simple, s3_post_config())

    render(conn, "index.json", credential: credential)
  end

  defp now, do: @current_time_interface.now()
  defp s3_post_config, do: Application.get_env(:mobile_markdown, :s3_post_config)
end
