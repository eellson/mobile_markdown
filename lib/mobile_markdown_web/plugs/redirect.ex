defmodule MobileMarkdownWeb.Redirect do
  @moduledoc """
  Simple plug handling request redirects
  """

  import Plug.Conn

  def init(opts), do: opts

  @doc """
  Redirects request

  Can be used in Router like so:

      get "/deprecated", Redirect, to: "/current"
  """
  def call(conn, opts) do
    conn
    |> Phoenix.Controller.redirect(opts)
    |> halt()
  end
end
