defmodule MobileMarkdownWeb.FakeUploadControllerTest do
  use MobileMarkdownWeb.ConnCase

  test "POST /new", %{conn: conn} do
    conn = post conn, "/fake_upload/new"
    refute response(conn, 201) =~ "<html"
    assert response(conn, 201) =~
      "<Location>http://example.bucket.com.amazonaws.com/example.png</Location>"
    assert response_content_type(conn, :xml)
    assert get_resp_header(conn, "access-control-allow-methods") == ["POST"]
    assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:4000"]
    assert get_resp_header(conn, "vary") == ["origin, access-control-request-headers, access-control-request-method"]
    assert get_resp_header(conn, "access-control-allow-credentials") == ["true"]
  end
end
