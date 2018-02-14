defmodule MobileMarkdownWeb.RedirectTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias MobileMarkdownWeb.Redirect

  defmodule TestRouter do
    use Phoenix.Router

    get("/deprecated", Redirect, to: "/current")
  end

  test "call/3 redirects request" do
    conn = call(TestRouter, :get, "/deprecated")

    assert conn.status == 302

    {"location", location_response} =
      conn.resp_headers
      |> Enum.find(fn
        {"location", _location} -> true
        _ -> false
      end)

    assert location_response == "/current"
  end

  defp call(router, verb, path) do
    verb
    |> Plug.Test.conn(path)
    |> router.call(router.init([]))
  end
end
