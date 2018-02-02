defmodule MobileMarkdown.CredentialsTest do
  use ExUnit.Case
  alias MobileMarkdown.Credentials

  # As required for x-amz-credential, from
  # https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTForms.html#w105aac20c21c21b8
  # as of 30-01-2018
  test "credential_string/0 returns string with key, date, region, service" do
    assert Credentials.credential_string == "PUBLIC-KEY/20180130/eu-west-1/s3/aws4_request"
  end
end
