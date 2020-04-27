defmodule AppWeb.OembedController do
  use AppWeb, :controller

  def oembed(conn, _) do
    conn
    |> fetch_from_cache()
    |> fetch()
    |> parse("oembed")
    |> serve()
  end

  def og(conn, _) do
    conn
    |> fetch_from_cache()
    |> fetch()
    |> parse("oembed")
    |> serve()
  end

  def raw(conn, _) do
    conn
    |> fetch_from_cache()
    |> fetch()
    |> parse("raw")
    |> serve()
  end

  #- Calculate the key and try the cache first
  def fetch_from_cache(%{params: %{"url" => url}} = conn) when byte_size(url) >= 10  do
    key = Utils.md5(url)
    ns = String.last(key)
    cache_file = Path.join([conn.assigns[:account].storage, ns, "#{key}.json"])
    cache_dir = Path.join([conn.assigns[:account].storage, ns])

    conn =
      case File.read(cache_file) do
        {:ok, data} -> 
          assign(conn, :data, Jason.decode!(data))

        {:error, reason} ->
          IO.puts "!!!! ERROR READING CACHE #{conn.assigns[:data_path]}: #{reason}"
          conn
      end

    conn
    |> assign(:data_id, key)
    |> assign(:data_path, cache_file)
    |> assign(:data_dir, cache_dir)
  end

  #- Fetch from the web
  def fetch(%{assigns: %{data: _}} = conn), do: conn
  def fetch(conn) do
    if data = Oginfo.fetch(conn.params["url"]) do
      unless File.exists?(conn.assigns[:data_dir]) do
        File.mkdir_p(conn.assigns[:data_dir])
      end

      case File.write(conn.assigns[:data_path], Jason.encode!(data)) do
        :ok ->
          assign(conn, :data, data)
        
        {:error, reason} ->
          IO.puts "!!!! ERROR WRITING CACHE #{conn.assigns[:data_path]}: #{reason}"
          conn
      end
    else
      conn
    end
  end

  #- Parse it as we need
  def parse(%{assigns: %{data: data}} = conn, parser) when is_map(data) do
    IO.inspect data
    case parser do
      "oembed" ->
        assign(conn, :data, Oginfo.Oembed.parse(data))

      "og" ->
        assign(conn, :data, Oginfo.Og.parse(data))

      _ ->
        conn
    end
  end
  def parse(conn), do: conn

  def serve(%{assigns: %{data: data}} = conn) when is_map(data) do
    json(conn, data)
  end

  def serve(conn) do
    conn
    |> put_resp_header("status", 404)
    |> json(%{error: "not found", url: conn.params["url"]})
  end

end
