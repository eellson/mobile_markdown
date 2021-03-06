defmodule MobileMarkdownWeb.Router do
  use MobileMarkdownWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :fake_aws do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  scope "/", MobileMarkdownWeb do
    pipe_through :browser # Use the default browser stack

    get "/", Redirect, to: "/editor"
    get "/editor", EditorController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", MobileMarkdownWeb do
    pipe_through :api

    resources "/credentials", CredentialController, only: [:index]
  end

  scope "/", MobileMarkdownWeb do
    pipe_through :fake_aws

    post "/fake_upload/new", FakeUploadController, :new
  end
end
