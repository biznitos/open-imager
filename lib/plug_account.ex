defmodule Plug.Account do

  def init(options), do: options

  #- Check endpoints
  def call(conn, _opts) do
    host =
      (conn.host || "localhost")
      |> String.trim()
      |> String.downcase()
      |> String.replace_leading("www.", "")
      |> String.trim()

    #- Grab endpoints
    endpoints = Application.get_env(:app, :imager)[:endpoints]

    if endpoints[host] do
      Plug.Conn.assign(conn, :account, endpoints[host])
    else
      if String.starts_with?(conn.request_path, "/subscribe") do
        Plug.Conn.assign(conn, :account, nil)
      else
        Phoenix.Controller.redirect(conn, to: "/subscribe")
      end
    end
  end

end
