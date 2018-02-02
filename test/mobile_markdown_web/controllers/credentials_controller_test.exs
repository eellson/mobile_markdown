defmodule MobileMarkdownWeb.CredentialsControllerTest do
  use MobileMarkdownWeb.ConnCase

  test "GET /credentials" do
    conn = get conn, "/credentials"
    assert html_response(conn, 200)
  end
end
