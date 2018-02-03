defmodule MobileMarkdown.AWSSigV4Test do
  use ExUnit.Case

  alias MobileMarkdown.AWSSigV4

  describe "credentials" do
    alias MobileMarkdown.AWSSigV4.Credential

    setup do
      date_string = "2018-02-02 19:07:03.568092Z"
      {:ok, datetime, _} = DateTime.from_iso8601(date_string)
      host = "http://www.example.com"
      config = Application.get_env(:mobile_markdown, :s3_post_config)

      %{datetime: datetime, host: host, config: config}
    end

    test "get_credential/5 returns populated %Credential{}", %{
      datetime: datetime,
      host: host,
      config: config
    } do
      credential = "#{config[:public_key]}/20180202/#{config[:region]}/s3/aws4_request"

      encoded_policy =
        %{
          "expiration" => "2018-02-02T19:07:33Z",
          "conditions" => [
            ["eq", "$bucket", config[:bucket]],
            ["eq", "$x-amz-credential", credential],
            ["eq", "$x-amz-date", "20180202T000000Z"],
            ["eq", "$x-amz-algorithm", "AWS4-HMAC-SHA256"],
            ["eq", "$success_action_status", "201"],
            ["starts-with", "$key", ""]
          ]
        }
        |> Poison.encode!()
        |> Base.encode64()

      calculated_signature =
        ("AWS4" <> config[:private_key])
        |> sha256("20180202")
        |> sha256(config[:region])
        |> sha256("s3")
        |> sha256("aws4_request")
        |> sha256(encoded_policy)
        |> Base.encode16(case: :lower)

      assert AWSSigV4.get_credential(host, datetime, :s3, :simple, config) ==
               %Credential{
                 host: host,
                 policy: encoded_policy,
                 x_amz_credential: credential,
                 x_amz_date: "20180202T000000Z",
                 x_amz_algorithm: "AWS4-HMAC-SHA256",
                 x_amz_signature: calculated_signature
               }
    end
  end # credentials

  def sha256(message, secret) do
    :crypto.hmac(:sha256, message, secret)
  end
end
