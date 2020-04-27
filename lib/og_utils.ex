defmodule Oginfo.Utils do

  def clean_social_string(""), do: nil
  def clean_social_string(nil), do: nil
  def clean_social_string(str) do
    "#{str}"
    |> String.replace(~r/\#[\w]+[\s\b\w]/ium, "")
    |> String.replace(~r/\n\.|[\n\r]+\.|[\n\r][\W]{1}/iu, " ")
    |> String.replace(~r/[\n\r\t ]+/iu, " ")
    |> String.replace(~r/[\-_\.\=\!]{3,128}/iu, " ")
    |> String.trim
  end

  @doc "Remove html entities from a string"
  def remove_html_entities(""), do: nil
  def remove_html_entities(nil), do: nil
  def remove_html_entities(str), do: HtmlEntities.decode(str)

  @doc "From a URL, get the base URL"
  def base_url(""), do: nil
  def base_url(nil), do: nil
  def base_url(url) do
    String.split(url, "/") 
      |> Enum.slice(0..2) 
      |> Enum.join("/")
      |> String.downcase
      |> String.trim
    #IO.puts url
    #URI.parse(url)
    #  |> Map.take([:schema, :authority, :port, :host]) 
    #  |> URI.to_string
  end

	@doc "Get a url, and follow redirects to the bitter end"
  def get_url(""), do: %{status: 500, message: "Bad URL"}
  def get_url(nil), do: %{status: 500, message: "Bad URL"}
  def get_url(url) do
    options = [
      {:follow_redirect, true},
      {:max_redirect, 12},
      ssl: [{:verify, :verify_none}]
    ]
    headers = [
      {"User-Agent", "GTTWL2/0.1"},
      {"From", "crawler@biznitos.com"},
    ]
    case HTTPoison.get(url, headers, options) do
      {:ok, response} ->
        %{
          headers: Enum.into(response.headers, %{}),
          status: response.status_code,
          body: response.body
        }
      {:error, %HTTPoison.Error{reason: reason}} ->
        %{status: 500, message: reason}
      _ ->
        %{status: 500, messsage: "Bad URL"}
    end
  end

  @doc "Unwind a url into its final destination"
  def unwind_url("", _redirs), do: nil
  def unwind_url(nil, _redirs), do: nil
  def unwind_url(url, redirs) do
    case HTTPoison.head(url) do
      {:ok, %HTTPoison.Response{status_code: 301, headers: head}} ->
        headers = Enum.into(head, %{})
        if redirs >= 12 do
          url
        else
          unwind_url(headers["Location"] || headers["location"], redirs + 1)
        end

      {:ok, %HTTPoison.Response{status_code: 200}} ->
        url

      {:ok, %HTTPoison.Response{status_code: 405}} ->
        url

      _ ->
        nil
    end
  end

  @doc "Cleanup a URL and remove any utm_* variables"
  def clean_url(url) do
    if url && String.length(url) > 0 do
      uri = URI.parse(url)

      if uri.authority && String.length(uri.authority) > 3 do
        if uri.query && String.length(uri.query) > 0 do
          q = uri.query
            |> URI.decode_query
            |> Map.drop(["utm_content", "utm_campaign", "utm_source", "utm_medium", "utm_term", "fbclid", "gclid", "glid"])

          case Enum.count(q) do
            0 -> Map.put(uri, :query, nil)
            _ -> Map.put(uri, :query, URI.encode_query(q))
          end
        end
        |> URI.to_string 
        |> String.trim
      else
        nil
      end
    else
      nil
    end
  end


  #
  #- Proper string to integer calls
  # (sigh)
  #
  def string_to_integer(nil), do: nil
  def string_to_integer(""), do: nil
  def string_to_integer(nstring) do
    String.to_integer(nstring)
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
	
  def to_int, do: nil
  def to_int(""), do: nil
  def to_int(nil), do: nil
  def to_int(str) when is_integer(str), do: str
  def to_int(str) when not is_binary(str), do: nil
  def to_int(str) when is_binary(str) do
    if String.match?(String.trim(str), ~r/^[0-9]+$/) do
      String.to_integer(String.trim(str))
    else
      nil
    end
  end

  def get_from_map(mapy, key) do
    case Map.fetch(mapy, key) do
      {:ok, val} -> val
      _ -> nil
    end
  end

  def extract_title("") do
    nil
  end

  def extract_title(nil) do
    nil
  end

  def extract_title(text) do
    parts = Regex.run(~r/^(.*?[\.\!\?\n\r]{1,2})/, String.trim(text))
    parts =
      if parts && Enum.count(parts) > 1 do
        parts
      else
        [text]
      end

    List.last(parts)
    |> String.trim
    |> String.replace_trailing(".", "")
    |> String.replace(~r/[\s]+/, " ")
    |> String.trim
    |> String.slice(0..128)
  end

  def extract_content(nil) do
    nil
  end

  def extract_content("") do
    nil
  end

  def extract_content(text) do
    text
      |> String.replace("\n.\n", "\n\n")
      |> Phoenix.HTML.Format.text_to_html
      |> Phoenix.HTML.safe_to_string
      |> String.trim
  end

  def extract_tags(nil), do: []
  def extract_tags(text) do
    parts = Regex.scan(~r/#([a-z_\-0-9]+)/, String.trim(String.downcase(text)))
    parts =
      if parts && Enum.count(parts) > 0 do
        List.flatten(parts)
      else
        []
      end

    parts
    |> Enum.map(fn(tag) ->
      String.trim(tag)
      |> String.replace("#", "")
      |> String.trim
    end)
    |> Enum.uniq
  end

  #- Make an MD5
  def md5(string) do
    :crypto.hash(:md5 , string) |> Base.encode16()
  end

  def days_in_last_month do
    Timex.today |> Timex.shift(months: 1) |> Timex.days_in_month
  end

  def days_in_this_month do
    Timex.today |> Timex.days_in_month
  end

  #
  # Just get the correct IP address
  #
  def get_request(conn, "ip") do
    req = Enum.into(conn.req_headers, %{})
    req["x-real-ip"] || (conn.remote_ip |> Tuple.to_list |> Enum.join("."))
  end

  #
  # Get some other thing
  #
  def get_request(conn, key) do
    Enum.into(conn.req_headers, %{})[key]
  end

  def convert_date(string) do
    case DateTime.from_iso8601(string) do
      {:ok, date, _} -> DateTime.to_naive(date)
      _ -> nil
    end
  end



end
