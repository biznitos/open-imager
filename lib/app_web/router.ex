defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :api do
    plug Plug.Account
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug Plug.Account
    plug :accepts, ["json", "html"]
  end

  scope "/v1", AppWeb do
    pipe_through :browser

    get "/oembed", OembedController, :oembed
    get "/og", OembedController, :og
    get "/raw", OembedController, :raw
    get "/image", ImageController, :index
  end

  scope "/", AppWeb do
    pipe_through :browser

    #- Subscribe endpoint
    get "/subscribe", PageController, :subscribe

    #- Image endpoints
    get "/*path", ImageController, :imgix

  end
end
