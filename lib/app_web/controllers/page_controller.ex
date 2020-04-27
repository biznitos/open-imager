defmodule AppWeb.PageController do
  use AppWeb, :controller

  def subscribe(conn, _) do
    host =
      (conn.host || "localhost")
      |> String.trim()
      |> String.downcase()
      |> String.replace_leading("www.", "")
      |> String.trim()

    conn
    |> put_resp_content_type("text") 
    |> send_resp(402, "IMAGER ERROR:\nPlease setup an endpoint in your config for \"#{host}\".")
  end
end
