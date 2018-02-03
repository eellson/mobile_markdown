defmodule MobileMarkdown.AWSSigV4 do
  @moduledoc """
  The AWSSigV4 context.
  """

  @aws_algorithm "AWS4-HMAC-SA256"

  alias MobileMarkdown.AWSSigV4.{Credential, S3}

  def get_credential(host, datetime, :s3, :simple, config) do
    with credential_string <-
           Credential.credential_string(datetime, config[:region], "s3", config[:public_key]),
         conditions <- simple_conditions(config[:bucket], credential_string, datetime),
         policy <- S3.policy(datetime, config[:ttl], conditions),
         signature <-
           Credential.signature(policy, datetime, config[:region], "s3", config[:private_key]) do
      %Credential{
        host: host,
        policy: policy,
        x_amz_credential: credential_string,
        x_amz_date: S3.date_string(datetime),
        x_amz_signature: signature,
        x_amz_algorithm: @aws_algorithm
      }
    end
  end

  defp simple_conditions(bucket, credential_string, date) do
    [
      ["eq", "$bucket", bucket],
      ["eq", "$x-amz-credential", credential_string],
      ["eq", "$x-amz-date", S3.date_string(date)],
      ["eq", "$x-amz-algorithm", @aws_algorithm],
      ["starts-with", "$key", ""]
    ]
  end
end
