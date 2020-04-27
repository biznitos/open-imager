defmodule AppWeb.ImageController do
  use AppWeb, :controller

  #----- Image resize using some vars 
  # Method: GET
  # Path: /image
  # Parameters:
  # url: the full URL of the original image
  # w: desired width
  # h: desired height
  # q: quality (10-100) percent
  # s: sharpen (radius)
  # auto: [enhance|sharpen|contrast]
  # fm: [jpeg|png|webp|gif]
  # dl: [filname.jpg] - download the image instead
  # dpr: [1-8] - default: 1 (72 dpi)
  #
  def index(conn, _) do
    conn
    |> identify()
    |> fetch()
    |> resize()
    |> serve()
  end

  #----- Use the Imgix format
  # https://s3.amazonaws.com/images.funadvice.com/v4/71314/7d4e8d1d-eb7c-418f-9fd1-c0a3033104d3.jpeg
  # https://s3.amazonaws.com/images.funadvice.com
  # http://<cname-path>/:image_path?opts=...
  # Same opts as index
  #
  def imgix(conn, %{"path" => []}) do
    text(conn, "No Image Given")
  end

  def imgix(conn, _) do
    if conn.assigns[:account] && conn.assigns[:account] do
      #- Endpoint parameters
      endpoint = conn.assigns[:account][:url]

      #- Inject URL into params
      params = Map.put(conn.params, "url", String.trim("#{endpoint}#{conn.request_path}"))
      conn = Map.put(conn, :params, params) 

      #- Spit out image
      conn
      |> identify()
      |> fetch()
      |> resize()
      |> serve()
    else
      text(conn, "No Image Endpoint")
    end
  end

  #- Identify the image and parameters and make a signature
  defp identify(%{params: %{"url" => url}} = conn) when byte_size(url) > 32 do
    #- Check if this is an image
    #- ====== If not an image we need to pass through ========
    
    id =
      conn.params
      |> Map.values()
      |> Enum.dedup()
      |> Enum.map(fn(v) -> String.trim("#{v}") end)
      |> Enum.reject(fn(v) -> is_nil(v) || v == "" end)
      |> Enum.join("|")
      |> String.trim()

    id = Utils.md5(id) 
    extname = Utils.extname(conn.params["url"])

    conn
    |> assign(:image_id, id)
    |> assign(:image_path, "#{conn.assigns[:account].storage}/#{String.last(Utils.md5(conn.params["url"]))}")
    |> assign(:image_filename, "#{conn.params["w"]}x#{conn.params["h"]}_#{id}#{extname}")
    |> assign(:image_geometry, Enum.join([conn.params["w"], conn.params["h"]], "x"))
  end

  defp identify(conn), do: assign(conn, :noimage, true)

  #- Try to fetch the file path from cache
  defp fetch(%{assigns: %{noimage: true}} = conn), do: conn
  defp fetch(conn) do

    unless File.exists?(conn.assigns[:image_path]) do
      File.mkdir_p(conn.assigns[:image_path])
    end

    cond do
      #- does the cropped image already exist?
      File.exists?(conn.assigns[:image_path] <> "/" <> conn.assigns[:image_filename]) ->
        assign(conn, :image_ready, conn.assigns[:image_path] <> "/" <> conn.assigns[:image_filename])

      #- does the original exist?
      File.exists?(conn.assigns[:image_path] <> "/" <> Utils.filename_from_url(conn.params["url"])) ->
        assign(conn, :image_original, conn.assigns[:image_path] <> "/" <> Utils.filename_from_url(conn.params["url"]))

      #- Try to download it
      orig = Utils.download(conn.params["url"], conn.assigns[:image_path]) ->
        App.Data.Action.add(conn, "download", conn.params["url"])
        assign(conn, :image_original, orig)

      true ->
        conn
    end

  end

  #--- resize it
  defp resize(%{assigns: %{noimage: true}} = conn), do: conn
  defp resize(%{assigns: %{image_ready: _}} = conn), do: conn
  
  defp resize(%{assigns: %{image_original: path, image_path: destination, image_filename: filename}} = conn) do
    if opath = Utils.resize_image(path, destination <> "/" <> filename, conn.params) do
      App.Data.Action.add(conn, "resize", opath)
      assign(conn, :image_ready, opath)
    else
      IO.puts "=== BAD IMAGE ===="
      assign(conn, :bad_image, "https://via.placeholder.com/640x480.png?text=No+Image")
    end
  end

  defp resize(conn), do: conn

  #-- serve it up! --
  defp serve(%{assigns: %{bad_image: placeholder}} = conn) do
    redirect(conn, external: placeholder)
  end

  defp serve(conn) do
    client_etag = Utils.get_request(conn, "if-none-match")

    cond do
      conn.assigns[:image_ready] ->
        server_etag = etag(conn.assigns[:image_ready])

        if server_etag == client_etag do
          conn
          |> send_resp(304, "")

        else
          App.Data.Action.add(conn, "image", conn.assigns[:image_ready])

          conn
          |> put_resp_header("content-type", MIME.from_path(conn.assigns[:image_ready]))
          |> put_resp_header("accept-ranges", "bytes")
          |> put_resp_header("cache-control", "public")
          |> put_resp_header("etag",  server_etag)
          |> send_file(200, conn.assigns[:image_ready])
        end

      conn.assigns[:image_original] ->
        App.Data.Action.add(conn, "original-image", conn.assigns[:image_original])

        conn
        |> put_resp_header("content-type", MIME.from_path(conn.assigns[:image_original]))
        |> put_resp_header("accept-ranges", "bytes")
        |> send_file(200, conn.assigns[:image_original])

      true ->
        conn
        |> put_resp_content_type("text")
        |> send_resp(404, "IMAGER ERROR:\n404 Image not found: \"#{conn.params["url"]}\"")
    end
  end

  defp etag(filename) do
    case File.stat(filename) do
      {:ok, stat} ->
        <<?", {stat.size, stat.mtime} |> :erlang.phash2() |> Integer.to_string(16)::binary, ?">>

      _ ->
        nil
    end
  end

end
