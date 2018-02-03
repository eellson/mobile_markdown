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

    test "with %DateTime{} generates string", %{datetime: datetime, region: region, service: service, public_key: public_key}  do
      assert Credential.credential_string(datetime, region, service, public_key) ==
        "AKIAIEUX27GZFAKECODE/20180202/us-east-1/s3/aws4_request"
    end

    test "with date string passed in generates string", %{region: region, service: service, public_key: public_key} do
      assert Credential.credential_string("20180202", region, service, public_key) ==
        "AKIAIEUX27GZFAKECODE/20180202/us-east-1/s3/aws4_request"
    end
  end
end
