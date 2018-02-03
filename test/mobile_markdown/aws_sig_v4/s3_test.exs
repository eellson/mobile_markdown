defmodule MobileMarkdown.AWSSigV4.S3Test do
  use ExUnit.Case

  alias MobileMarkdown.AWSSigV4.{S3, Credential}

  describe "credentials" do
    setup do
      date_string = "2018-02-02 19:07:03.568092Z"
      {:ok, datetime, _} = DateTime.from_iso8601(date_string)

      options = [
        host: "http://www.example.com",
        bucket: [name: "my-bucket", region: "us-east-1"],
        datetime_now: datetime,
        expires_in: 30,
        public_key: "AKIAIEUX27GZFAKECODE",
        private_key: "M1jAHjgpZ6FnXCErcY8/ANOTHERFAKECODEEEEEEEE"
      ]

      credential = "#{options[:public_key]}/20180202/#{options[:bucket][:region]}/s3/aws4_request"

      simple_policy = %{"expiration" => "2018-02-02T19:07:33Z",
        "conditions" => [
        ["eq", "$bucket", "my-bucket"],
        ["eq", "$x-amz-credential", credential],
        ["eq", "$x-amz-date", "20180202T000000Z"],
        ["eq", "$x-amz-algorithm", "AWS4-HMAC-SA256"],
        ["starts-with", "$key", ""]
      ]}

      %{options: options, policy: simple_policy, credential: credential}
    end

    test "get_credentials/1 returns populated %Credential{}", %{options: options, credential: credential, policy: policy} do
      base64_encoded_policy = policy |> Poison.encode!() |> Base.encode64()

      calculated_signature =
        "AWS4" <> options[:private_key]
        |> sha256("20180202")
        |> sha256(options[:bucket][:region])
        |> sha256("s3")
        |> sha256("aws4_request")
        |> sha256(base64_encoded_policy)
        |> Base.encode16(case: :lower)

      assert S3.get_credential(options) == %Credential{
        host: Keyword.get(options, :host),
        policy: base64_encoded_policy,
        x_amz_credential: credential,
        x_amz_date:  "20180202T000000Z",
        x_amz_algorithm: "AWS4-HMAC-SA256",
        x_amz_signature: calculated_signature
      }
    end
  end

  def sha256(message, secret) do
    :crypto.hmac(:sha256, message, secret)
  end
end
