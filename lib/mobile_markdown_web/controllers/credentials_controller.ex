defmodule MobileMarkdownWeb.CredentialsController do
  use MobileMarkdownWeb, :controller
  alias MobileMarkdown.Credentials
  alias MobileMarkdown.Credentials.S3

  def show(conn, _params) do
    with now <- DateTime.utc_now(),
         host <- url(conn),
         credential <- S3.credential_string(public_key(), now, region()),
         policy <- S3.simple_policy(credential, bucket(), now, expires_in()),
         signature <- S3.signature(policy, now, region(), private_key()) do
      render(conn, "credentials.json", %{
        host: host,
        credential_string: credential,
        date: Credentials.date_string(now) <> "T000000Z",
        policy: policy,
        signature: signature
      })
    end
  end

  defp public_key, do: Application.get_env(:mobile_markdown, :aws_s3_public_key)

  defp private_key, do: Application.get_env(:mobile_markdown, :aws_s3_private_key)

  defp region, do: Application.get_env(:mobile_markdown, :aws_s3_region)

  defp bucket, do: Application.get_env(:mobile_markdown, :aws_s3_bucket)

  defp expires_in, do: 30
end
