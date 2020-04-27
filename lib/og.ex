defmodule Oginfo do

  @doc "Fetch OG Info"
  def fetch(nil), do: nil
  def fetch(""), do: nil
  def fetch(url) do
    page = Utils.get_url(url)
    if page do
     	og_parse2(page, url) 
    else
      nil
    end
  end

  defp og_parse2(source, url) do
    html = 
      case Floki.parse_document(source) do
        {:ok, doc} ->
          doc
        _ ->
          nil
      end

    #- Grab all the meta name or properties
    meta =
      for m <- Floki.find(html, "meta") do
        key = Floki.attribute(m, "name") |> List.first
          || Floki.attribute(m, "property") |> List.first
        val = Floki.attribute(m, "content") |> List.first
        {key,val}
      end
        |> Enum.into(%{})

    #- Grab link rel alternates
    links = 
      for m <- Floki.find(html, "link[rel=alternate]") do
        key = Floki.attribute(m, "type") |> List.first
        val = Floki.attribute(m, "href") |> List.first
        {key, val}
      end
      |> Enum.into(%{})

    #- And title
    meta = Map.put(meta, "title", Floki.find(html, "title") |> Floki.text)

    #- And canonical
    meta = Map.put(meta, "canonical", Floki.find(html, "link[rel^=canonical]") |> Floki.attribute("href") |> List.first)

    #- Maybe oembed too
    oembed = get_oembed(links)

    #- Cleanup into groups now
    %{
      "url" => url,
      "oembed" => oembed,
      "og" => Enum.filter(meta, fn(d) -> String.starts_with?(elem(d, 0) || "", "og:") end) |> Enum.into(%{}),
      "twitter" => Enum.filter(meta, fn(d) -> String.starts_with?(elem(d, 0) || "", "twitter:") end) |> Enum.into(%{}),
      "video" => Enum.filter(meta, fn(d) -> String.starts_with?(elem(d, 0) || "", "video:") end) |> Enum.into(%{}),
      "native" => Enum.reject(meta, fn(d) -> String.contains?(elem(d, 0) || "", ":") end) |> Enum.into(%{}), 
      "alternates" => links,
    }
  end

  #- Find an appropriate hash
  defp get_oembed(%{"application/json+oembed" => url}) do
    IO.puts "JSON Oembed parser"
    case Oginfo.Utils.get_url(url) do
      %{status: 200, body: body} -> Jason.decode!(body)
      _ -> %{}
    end
  end
  
  defp get_oembed(%{"text/xml+oembed" => url}) do
    IO.puts "XML Oembed parser"
    case Oginfo.Utils.get_url(url) do
      %{status: 200, body: body} ->
        XmlToMap.naive_map(body)["oembed"]
      _ -> 
        %{}
    end
  end

  defp get_oembed(%{}), do: %{}

end

