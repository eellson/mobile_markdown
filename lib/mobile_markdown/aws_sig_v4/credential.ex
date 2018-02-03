defmodule MobileMarkdown.AWSSigV4.Credential do
  @aws_request "aws4_request"

  defstruct [:host, :policy, :x_amz_credential, :x_amz_date, :x_amz_algorithm, :x_amz_signature]

  def credential_string(%DateTime{} = datetime, region, service, public_key) do
    credential_string(yyyymmdd(datetime), region, service, public_key)
  end

  def credential_string(datetime, region, service, public_key) do
    Enum.join([public_key, datetime, region, service, @aws_request], "/")
  end

  defp yyyymmdd(datetime), do: Date.to_iso8601(datetime, :basic)
end
