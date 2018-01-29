defmodule MobileMarkdownWeb.PageController do
  use MobileMarkdownWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
