defmodule MobileMarkdown.AWSSigV4.S3 do
  alias MobileMarkdown.AWSSigV4.Credential

  @aws_service "s3"
  @aws_algorithm "AWS4-HMAC-SA256"

  def get_credential(
        host: host,
        bucket: [name: bucket, region: region],
        datetime_now: now,
        expires_in: expires_in,
        public_key: public_key,
        private_key: private_key
      ) do
    with credential_string <- Credential.credential_string(now, region, @aws_service, public_key),
         policy <- simple_policy(credential_string, bucket, now, expires_in),
         signature <- Credential.signature(policy, now, region, @aws_service, private_key) do
      %Credential{
        host: host,
        policy: policy,
        x_amz_credential: credential_string,
        x_amz_date: date_string(now),
        x_amz_signature: signature,
        x_amz_algorithm: @aws_algorithm
      }
    end
  end

  defp simple_policy(credential_string, bucket, start_time, expires_in) do
    conditions = [
      ["eq", "$bucket", bucket],
      ["eq", "$x-amz-credential", credential_string],
      ["eq", "$x-amz-date", date_string(start_time)],
      ["eq", "$x-amz-algorithm", @aws_algorithm],
      ["starts-with", "$key", ""]
    ]

    start_time
    |> expires_at(expires_in)
    |> policy(conditions)
  end

  defp date_string(datetime) do
    datetime |> Date.to_iso8601(:basic) |> Kernel.<>("T000000Z")
  end

  defp expires_at(datetime, expires_in) do
    datetime
    |> DateTime.truncate(:second)
    |> DateTime.to_naive()
    |> NaiveDateTime.add(expires_in)
    |> NaiveDateTime.to_iso8601()
    |> Kernel.<>("Z")
  end

  defp policy(expiry, conditions) do
    %{"expiration" => expiry, "conditions" => conditions}
    |> Poison.encode!()
    |> Base.encode64()
  end
end
