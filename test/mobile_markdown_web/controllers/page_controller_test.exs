defmodule MobileMarkdownWeb.PageControllerTest do
  use MobileMarkdownWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<div id=\"elm-target\">"
  end
end
