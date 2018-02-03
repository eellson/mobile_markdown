defmodule MobileMarkdownWeb.CredentialControllerTest do
  use MobileMarkdownWeb.ConnCase

  import Mox

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "returns credential", %{conn: conn} do
      MobileMarkdown.CurrentTimeMock
      |> expect(:now, fn ->
        {:ok, datetime, _} = DateTime.from_iso8601("2018-02-02 19:07:03.568092Z")
        datetime
      end)

      conn = get(conn, credential_path(conn, :index))

      assert json_response(conn, 200)["data"] == %{
               "host" => "http://localhost:4001",
               "x_amz_algorithm" => "AWS4-HMAC-SA256",
               "x_amz_date" => "20180202T000000Z",
               "policy" =>
                 "eyJleHBpcmF0aW9uIjoiMjAxOC0wMi0wMlQxOTowNzozM1oiLCJjb25kaXRpb25zIjpbWyJlcSIsIiRidWNrZXQiLCJteS1idWNrZXQiXSxbImVxIiwiJHgtYW16LWNyZWRlbnRpYWwiLCJBS0lBSUVVWDI3R1pGQUtFQ09ERS8yMDE4MDIwMi91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0Il0sWyJlcSIsIiR4LWFtei1kYXRlIiwiMjAxODAyMDJUMDAwMDAwWiJdLFsiZXEiLCIkeC1hbXotYWxnb3JpdGhtIiwiQVdTNC1ITUFDLVNBMjU2Il0sWyJzdGFydHMtd2l0aCIsIiRrZXkiLCIiXV19",
               "x_amz_credential" => "AKIAIEUX27GZFAKECODE/20180202/us-east-1/s3/aws4_request",
               "x_amz_signature" =>
                 "a1e164ea3f76137c72f1bf22c299848fc985b8c67a492d1d48a4ebb6ed1153b1"
             }
    end
  end
end
