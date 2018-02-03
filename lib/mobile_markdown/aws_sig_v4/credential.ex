defmodule MobileMarkdown.AWSSigV4.Credential do
  @moduledoc """
  General helper functions for generating credential values.

  These should not be dependent on any particular AWS service.
  """

  @aws_request "aws4_request"
  @key_prefix "AWS4"

  defstruct [:host, :policy, :x_amz_credential, :x_amz_date, :x_amz_algorithm, :x_amz_signature]

  @doc """
  Returns string to be used for credential.

  For example, to be used as the `x-amz-credential` field's value when
  submitting an S3 POST.
  """
  @spec credential_string(DateTime.t(), String.t(), String.t(), String.t()) :: String.t()
  @spec credential_string(String.t(), String.t(), String.t(), String.t()) :: String.t()
  def credential_string(%DateTime{} = datetime, region, service, public_key) do
    credential_string(yyyymmdd(datetime), region, service, public_key)
  end

  def credential_string(date, region, service, public_key) do
    Enum.join([public_key, date, region, service, @aws_request], "/")
  end

  @doc """
  Returns signature for authenticating requests

  https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-UsingHTTPPOST.html#sigv4-post-signature-calc
  """
  @spec signature(String.t(), DateTime.t(), String.t(), String.t(), String.t()) :: String.t()
  @spec signature(String.t(), String.t(), String.t(), String.t(), String.t()) :: String.t()
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
