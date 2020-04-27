defmodule AppWeb.MainController do
  use AppWeb, :controller

  def index(conn, _) do
    text(conn, "Upyet")
  end
end