defmodule MobileMarkdown.AWSSigV4.CredentialTest do
  use ExUnit.Case, async: true

  alias MobileMarkdown.AWSSigV4.Credential

  describe "credential_string/4" do
    setup do
      {:ok, datetime, _} = DateTime.from_iso8601("2018-02-02 19:07:03.568092Z")
      region = "us-east-1"
      service = "s3"
      public_key = "AKIAIEUX27GZFAKECODE"

      [datetime: datetime, region: region, service: service, public_key: public_key]
    end

    test "with %DateTime{} generates string", %{
      datetime: datetime,
      region: region,
      service: service,
      public_key: public_key
    } do
      assert Credential.credential_string(datetime, region, service, public_key) ==
               "AKIAIEUX27GZFAKECODE/20180202/us-east-1/s3/aws4_request"
    end

    test "with date string passed in generates string", %{
      region: region,
      service: service,
      public_key: public_key
    } do
      assert Credential.credential_string("20180202", region, service, public_key) ==
               "AKIAIEUX27GZFAKECODE/20180202/us-east-1/s3/aws4_request"
    end
  end # credential_string/4

  describe "signature/5" do
    setup do
      # Example input from AWS docs: https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-post-example.html
      # however, the generated signature on that page seems to be wrong!
      # My signature matches the one seen here: https://stackoverflow.com/a/47742378/8938412
      string_to_sign =
        "eyAiZXhwaXJhdGlvbiI6ICIyMDE1LTEyLTMwVDEyOjAwOjAwLjAwMFoiLA0KICAiY29uZGl0aW9ucyI6IFsNCiAgICB7ImJ1Y2tldCI6ICJzaWd2NGV4YW1wbGVidWNrZXQifSwNCiAgICBbInN0YXJ0cy13aXRoIiwgIiRrZXkiLCAidXNlci91c2VyMS8iXSwNCiAgICB7ImFjbCI6ICJwdWJsaWMtcmVhZCJ9LA0KICAgIHsic3VjY2Vzc19hY3Rpb25fcmVkaXJlY3QiOiAiaHR0cDovL3NpZ3Y0ZXhhbXBsZWJ1Y2tldC5zMy5hbWF6b25hd3MuY29tL3N1Y2Nlc3NmdWxfdXBsb2FkLmh0bWwifSwNCiAgICBbInN0YXJ0cy13aXRoIiwgIiRDb250ZW50LVR5cGUiLCAiaW1hZ2UvIl0sDQogICAgeyJ4LWFtei1tZXRhLXV1aWQiOiAiMTQzNjUxMjM2NTEyNzQifSwNCiAgICB7IngtYW16LXNlcnZlci1zaWRlLWVuY3J5cHRpb24iOiAiQUVTMjU2In0sDQogICAgWyJzdGFydHMtd2l0aCIsICIkeC1hbXotbWV0YS10YWciLCAiIl0sDQoNCiAgICB7IngtYW16LWNyZWRlbnRpYWwiOiAiQUtJQUlPU0ZPRE5ON0VYQU1QTEUvMjAxNTEyMjkvdXMtZWFzdC0xL3MzL2F3czRfcmVxdWVzdCJ9LA0KICAgIHsieC1hbXotYWxnb3JpdGhtIjogIkFXUzQtSE1BQy1TSEEyNTYifSwNCiAgICB7IngtYW16LWRhdGUiOiAiMjAxNTEyMjlUMDAwMDAwWiIgfQ0KICBdDQp9"

      {:ok, datetime, _} = DateTime.from_iso8601("2015-12-29T00:00:00.000Z")
      region = "us-east-1"
      service = "s3"
      private_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

      [
        string_to_sign: string_to_sign,
        datetime: datetime,
        region: region,
        service: service,
        private_key: private_key
      ]
    end

    test "with %DateTime{} correctly encodes signature", %{
      string_to_sign: string_to_sign,
      datetime: datetime,
      region: region,
      service: service,
      private_key: private_key
    } do
      assert Credential.signature(string_to_sign, datetime, region, service, private_key) ==
               "8afdbf4008c03f22c2cd3cdb72e4afbb1f6a588f3255ac628749a66d7f09699e"
    end

    test "with date string correctly encodes signature", %{
      string_to_sign: string_to_sign,
      region: region,
      service: service,
      private_key: private_key
    } do
      assert Credential.signature(string_to_sign, "20151229", region, service, private_key) ==
               "8afdbf4008c03f22c2cd3cdb72e4afbb1f6a588f3255ac628749a66d7f09699e"
    end
  end # signature/5
end
