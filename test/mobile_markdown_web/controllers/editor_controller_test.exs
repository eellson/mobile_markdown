defmodule MobileMarkdownWeb.EditorControllerTest do
  use MobileMarkdownWeb.ConnCase

  test "GET /editor", %{conn: conn} do
    conn = get conn, "/editor"
    assert html_response(conn, 200) =~ "<div id=\"elm-target\""
  end
end
