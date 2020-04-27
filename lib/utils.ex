defmodule Utils do

  def to_int, do: nil
  def to_int(""), do: nil
  def to_int(nil), do: nil
  def to_int(str) when is_integer(str), do: str
  def to_int(str) when is_float(str), do: round(str)
  def to_int(str) when not is_binary(str), do: nil
  def to_int(str) when is_binary(str) do
    if String.match?(String.trim(str), ~r/^[\-0-9\.]+$/) do
      str
      |> String.trim
      |> String.split(".")
      |> List.first
      |> String.trim
      |> String.to_integer
    else
      nil
    end
  end

  def to_int_or_zero(num) do
    to_int(num) || 0
  end

  @doc "Get a url, and follow redirects to the bitter end"
  def get_url(""), do: %{status: 500, message: "Bad URL"}
  def get_url(nil), do: %{status: 500, message: "Bad URL"}
  def get_url(url) do
    options = [
      {:follow_redirect, true},
      {:max_redirect, 12}
    ]
    headers = [
      {"User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"}
    ]
    case HTTPoison.get(url, headers, options) do
      {:ok, response} ->
        response.body
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        nil
      _ ->
        IO.puts "-- bad url --"
        nil
    end
  end

  #- Make an MD5
  def md5(string) do
    :crypto.hash(:md5 , string) |> Base.encode16(case: :lower)
  end

  #
  # Just get the correct IP address
  #
  def get_request(conn, "ip") do
    req = Enum.into(conn.req_headers, %{})
    req["x-forwarded-for"] || 
    req["X-Forwarded-For"] ||
    req["X-Real-IP"] || 
    (conn.remote_ip |> Tuple.to_list |> Enum.join("."))
  end

  #
  # Get some other thing
  #
  def get_request(conn, key) do
    Enum.into(conn.req_headers, %{})[key]
  end

  @doc "Grab a domain from a url"
  def domain(url) do
    if url && String.length(url) > 0 do
      uri = URI.parse(url)
      if uri.authority && String.length(uri.authority) > 3 do
        uri.authority |> String.downcase |> String.trim |> String.replace("www.", "")
      else
        nil
      end
    else
      nil
    end
  end

  def extname(path) do
    path 
    |> String.split("?")
    |> List.first()
    |> String.trim()
    |> Path.extname()
    |> String.downcase()
  end

  def filename_from_url(url) do
    md5(url) <> extname(url)  
  end

  #- Download a file at URL,
  #- Returns something like <image>.<ext>
  #- <image>: a unique filename
  #- <ext>: the extension of the image
  def download(url, destination_dir) do
    case Utils.get_url(url) do
      nil ->
        nil

      body ->
        path = "#{destination_dir}/#{filename_from_url(url)}"
        File.mkdir_p(destination_dir)
        File.write(path, body)
        if File.exists?(path) do
          path
        end
    end
  end

 	def identify(path) do
    case System.cmd("identify", ["-format", "%w:%h:%m:%t", path]) do
      {ret, 0} ->
        parts = String.split(ret, ":")
        %{
          path: path,
          type: Enum.at(parts, 2),
          width: String.to_integer(Enum.at(parts, 0)),
          height: String.to_integer(Enum.at(parts,1))
        }
      {ret, num} ->
        IO.puts "== ERROR identifying image: #{ret}, error #{num} ==="
        nil
    end
  end

  def resize_image(source, destination, opts \\ %{}) do

    #- Basic values
    w = to_int(opts["w"]) || 0
    h = to_int(opts["h"]) || 0
    quality = to_int(opts["q"]) || 65 
    format = opts["fm"] || "jpg"

    #- Is this an image?
    if info = identify(source) do
      #- Set defaults as same of image
      {w, h} = 
        if w == 0 && h == 0 do
          {info.width, info.height}
        else
          {w, h}
        end

      #- Startup
      image = Mogrify.open(source)

      image =
        cond do
          #- thumbnail
          !is_nil(w) && !is_nil(h) && w == h ->
            image 
            |> Mogrify.custom("thumbnail", "#{w}x#{h}^")
            |> Mogrify.custom("gravity", "center")
            |> Mogrify.custom("crop", "#{w}x#{h}+0+0")

          #- two dimensions, crop and fill
          true ->
            h = if h == "" || is_nil(h), do: 0, else: h
            w = if w == "" || is_nil(w), do: 0, else: w
            Mogrify.resize_to_fill(image, "#{w}x#{h}")
        end

      #- Enhance in some way
      image =
        case opts["auto"] do
          "sharpen" ->
            Mogrify.custom(image, "adaptive-sharpen", "0x1.5")

          "enhance" ->
            Mogrify.custom(image, "enhance")

          "contrast" ->
            Mogrify.custom(image, "contrast")

          _ ->
            image
        end

      #- Set density
      image =
        if density = Utils.to_int(opts["dpr"]) do
          if density >= 1 && density <= 8 do
            Mogrify.custom(image, "density", density * 72)
          else
            image
          end
        else
          image
        end

      #- Final arguments
      image =
        image
        |> Mogrify.quality(quality)
        |> Mogrify.format(format)
        |> Mogrify.custom("strip")

      #- Write out the image
      Mogrify.save(image, path: destination)

      if File.exists?(destination) do
        destination
      end

    else
      #- Whoops! Not an image
      nil 
    end
  end


end
