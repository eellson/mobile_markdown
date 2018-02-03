defmodule MobileMarkdown.AWSSigV4.S3Test do
  use ExUnit.Case

  alias MobileMarkdown.AWSSigV4.S3

  describe "policy/3" do
    setup do
      start_time_iso = "2015-12-29T12:00:00.000Z"
      {:ok, start_time, _} = DateTime.from_iso8601(start_time_iso)
      expires_in = 86400

      conditions = [
        %{"bucket" => "sigv4examplebucket"},
        ["starts-with", "$key", "user/user1/"],
        %{"acl" => "public-read"},
        %{
          "success_action_redirect" =>
            "http://sigv4examplebucket.s3.amazonaws.com/successful_upload.html"
        },
        ["starts-with", "$Content-Type", "image/"],
        %{"x-amz-meta-uuid" => "14365123651274"},
        %{"x-amz-server-side-encryption" => "AES256"},
        ["starts-with", "$x-amz-meta-tag", ""],
        %{"x-amz-credential" => "AKIAIOSFODNN7EXAMPLE/20151229/us-east-1/s3/aws4_request"},
        %{"x-amz-algorithm" => "AWS4-HMAC-SHA256"},
        %{"x-amz-date" => "20151229T000000Z"}
      ]

      %{start_time: start_time, expires_in: expires_in, conditions: conditions}
    end

    test "returns encoded policy", %{
      start_time: start_time,
      expires_in: expires_in,
      conditions: conditions
    } do
      assert S3.policy(start_time, expires_in, conditions) ==
        "eyJleHBpcmF0aW9uIjoiMjAxNS0xMi0zMFQxMjowMDowMFoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJzaWd2NGV4YW1wbGVidWNrZXQifSxbInN0YXJ0cy13aXRoIiwiJGtleSIsInVzZXIvdXNlcjEvIl0seyJhY2wiOiJwdWJsaWMtcmVhZCJ9LHsic3VjY2Vzc19hY3Rpb25fcmVkaXJlY3QiOiJodHRwOi8vc2lndjRleGFtcGxlYnVja2V0LnMzLmFtYXpvbmF3cy5jb20vc3VjY2Vzc2Z1bF91cGxvYWQuaHRtbCJ9LFsic3RhcnRzLXdpdGgiLCIkQ29udGVudC1UeXBlIiwiaW1hZ2UvIl0seyJ4LWFtei1tZXRhLXV1aWQiOiIxNDM2NTEyMzY1MTI3NCJ9LHsieC1hbXotc2VydmVyLXNpZGUtZW5jcnlwdGlvbiI6IkFFUzI1NiJ9LFsic3RhcnRzLXdpdGgiLCIkeC1hbXotbWV0YS10YWciLCIiXSx7IngtYW16LWNyZWRlbnRpYWwiOiJBS0lBSU9TRk9ETk43RVhBTVBMRS8yMDE1MTIyOS91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxNTEyMjlUMDAwMDAwWiJ9XX0="
    end
  end

  describe "date_string/1" do
    test "returns date portion with appended midnight indicator" do
      datetime_iso = "2015-12-29T12:00:00.000Z"
      {:ok, datetime, _} = DateTime.from_iso8601(datetime_iso)

      assert S3.date_string(datetime) == "20151229T000000Z"
    end
  end
end
