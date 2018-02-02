defmodule MobileMarkdown.Credentials.S3 do
  alias MobileMarkdown.Credentials

  @service "s3"
  @aws_algorithm "AWS4-HMAC-SHA256"

  def credential_string(key, now, region) do
    Credentials.credential_string(key, now, region, @service)
  end

  def signature(policy, now, region, private_key) do
    Credentials.signature(policy, now, region, @service, private_key)
  end

  def simple_policy(credential, bucket, now, expires_in) do
    conditions = [
      ["eq", "$bucket", bucket],
      ["eq", "$x-amz-credential", credential],
      ["eq", "$x-amz-date", Credentials.date_string(now) <> "T000000Z"],
      ["eq", "$x-amz-algorithm", @aws_algorithm],
      ["starts-with", "$key", ""]
    ]

    now
    |> expires_at(expires_in)
    |> policy(conditions)
  end

  def policy(expires_at, conditions) do
    %{"expiration" => expires_at, "conditions" => conditions}
    |> Poison.encode!()
    |> Base.encode64()
  end

  def expires_at(initial, additional) do
    initial
    |> DateTime.truncate(:second)
    |> DateTime.to_naive()
    |> NaiveDateTime.add(additional)
    |> NaiveDateTime.to_iso8601()
    |> Kernel.<>("Z")
  end
end
