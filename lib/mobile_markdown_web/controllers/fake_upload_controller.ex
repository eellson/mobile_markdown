defmodule MobileMarkdownWeb.FakeUploadController do
  use MobileMarkdownWeb, :controller

  def new(conn, _params) do
    conn
    |> put_layout(false)
    |> put_status(201)
    |> put_cors_headers()
    |> render("success.xml")
  end

  defp put_cors_headers(conn) do
    conn
    |> put_resp_content_type("application/xml")
    |> put_resp_header("access-control-allow-methods", "POST")
    |> put_resp_header("access-control-allow-origin", "http://localhost:4000")
    |> put_resp_header("vary", "origin, access-control-request-headers, access-control-request-method")
    |> put_resp_header("access-control-allow-credentials", "true")
  end
end
