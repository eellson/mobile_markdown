defmodule MobileMarkdown.Credentials do
  @key_prefix "AWS4"
  @aws_req "aws4_request"

  def credential_string(public_key, %DateTime{} = now, region, service) do
    credential_string(public_key, date_string(now), region, service)
  end

  def credential_string(public_key, date_string, region, service) do
    public_key <> "/" <> date_string <> "/" <> region <> "/" <> service <> "/" <> @aws_req
  end

  def signature(policy, now, region, service, private_key) do
    @key_prefix <> private_key
    |> hash_sha256(date_string(now))
    |> hash_sha256(region)
    |> hash_sha256(service)
    |> hash_sha256(@aws_req)
    |> hash_sha256(policy)
    |> Base.encode16(case: :lower)
  end

  def hash_sha256(secret, message), do: :crypto.hmac(:sha256, secret, message)

  def date_string(datetime_now), do: Date.to_iso8601(datetime_now, :basic)
end
