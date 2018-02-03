defmodule MobileMarkdown.AWSSigV4.Credential do
  @moduledoc """
  General helper functions for generating credential values.

  These should not be dependent on any particular AWS service.
  """

  @aws_request "aws4_request"
  @key_prefix "AWS4"

  defstruct [:host, :policy, :x_amz_credential, :x_amz_date, :x_amz_algorithm, :x_amz_signature]

  def credential_string(%DateTime{} = datetime, region, service, public_key) do
    credential_string(yyyymmdd(datetime), region, service, public_key)
  end

  def credential_string(date, region, service, public_key) do
    Enum.join([public_key, date, region, service, @aws_request], "/")
  end

  def signature(string_to_sign, %DateTime{} = datetime, region, service, private_key) do
    signature(string_to_sign, yyyymmdd(datetime), region, service, private_key)
  end

  def signature(string_to_sign, date, region, service, private_key) do
    (@key_prefix <> private_key)
    |> sha256(date)
    |> sha256(region)
    |> sha256(service)
    |> sha256(@aws_request)
    |> sha256(string_to_sign)
    |> Base.encode16(case: :lower)
  end

  defp yyyymmdd(datetime), do: Date.to_iso8601(datetime, :basic)

  defp sha256(key, data), do: :crypto.hmac(:sha256, key, data)
end
