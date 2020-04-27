defmodule Oginfo.Oembed do

  # http://docs.embed.ly/v1.0/docs/oembed

  def parse(schema) do
    %{"version" => "1.0", "type" => nil}
      |> get_title(schema)
      |> get_description(schema)
      |> get_author_name(schema)
      |> get_author_url(schema)
      |> get_provider_name(schema)
      |> get_provider_url(schema)
      |> get_url(schema)
      |> get_domain(schema)
      |> get_embed_height(schema)
      |> get_embed_width(schema)
      |> get_thumbnail_url(schema)
      |> get_video(schema)
      |> get_photo(schema)
      |> get_rich(schema)
      |> get_type(schema)
      |> get_currency(schema)
      |> get_price(schema)
      |> get_brand(schema)
      |> get_locale(schema)
  end

  defp get_locale(o, %{"og" => %{"og:locale" => locale}}), do: Map.put(o, "locale", locale |> Oginfo.Utils.remove_html_entities)
  defp get_locale(o, _), do: o

  defp get_brand(o, %{"oembed" => %{"brand" => brand}}), do: Map.put(o, "brand", brand |> Oginfo.Utils.remove_html_entities)
  defp get_brand(o, _), do: o

  defp get_price(o, %{"og" => %{"og:price:amount" => price}}), do: Map.put(o, "price", price |> Oginfo.Utils.remove_html_entities)
  defp get_price(o, %{"oembed" => %{"offers" => offers}}) when is_list(offers) do
    if offer = List.first(offers) do
      if Map.has_key?(offer, "price"), do: Map.put(o, "price", offer["price"]), else: o
    else
      o
    end
  end
  defp get_price(o, _), do: o

  defp get_currency(o, %{"og" => %{"og:price:currency" => currency}}), do: Map.put(o, "currency", currency |> Oginfo.Utils.remove_html_entities)
  defp get_currency(o, %{"oembed" => %{"offers" => offers}}) when is_list(offers) do
    if offer = List.first(offers) do
      if Map.has_key?(offer, "currency_code"), do: Map.put(o, "currency", offer["currency_code"]), else: o
    else
      o
    end
  end
  defp get_currency(o, _), do: o

  defp get_type(o, %{"og" => %{"og:type" => og_type}}), do: Map.put(o, "type", og_type)
  defp get_type(o, %{"oembed" => %{"type" => o_type}}), do: Map.put(o, "type", o_type)
  defp get_type(o, _), do: Map.put(o, "type", "link")

  #- Figure out title
  defp get_title(o, %{"oembed" => %{"title" => title}}), do: Map.put(o, "title", title |> Oginfo.Utils.remove_html_entities)
  defp get_title(o, %{"og" => %{"og:title" => title}}), do: Map.put(o, "title", title |> Oginfo.Utils.remove_html_entities)
  defp get_title(o, %{"twitter" => %{"title" => title}}), do: Map.put(o, "title", title |> Oginfo.Utils.remove_html_entities)
  defp get_title(o, %{"native" => %{"title" => title}}), do: Map.put(o, "title", title |> Oginfo.Utils.remove_html_entities) 
  defp get_title(o, _), do: o

  #- Figure out description
  defp get_description(o, %{"oembed" => %{"description" => desc}}), do: Map.put(o, "description", desc |> Oginfo.Utils.remove_html_entities |> HtmlSanitizeEx.strip_tags())
  defp get_description(o, %{"og" => %{"og:description" => desc}}), do: Map.put(o, "description", desc |> Oginfo.Utils.remove_html_entities |> HtmlSanitizeEx.strip_tags())
  defp get_description(o, %{"native" => %{"description" => desc}}), do: Map.put(o, "description", desc |> Oginfo.Utils.remove_html_entities |> HtmlSanitizeEx.strip_tags())
  defp get_description(o, _), do: Map.put(o, "description", nil)

  #- Author name
  defp get_author_name(o, %{"oembed" => %{"author_name" => name}}), do: Map.put(o, "author_name", name |> Oginfo.Utils.remove_html_entities)
  defp get_author_name(o, %{"og" => %{"og:article:author" => name}}), do: Map.put(o, "author_name", name |> Oginfo.Utils.remove_html_entities)
  defp get_author_name(o, %{"og" => %{"og:book:author" => name}}), do: Map.put(o, "author_name", name |> Oginfo.Utils.remove_html_entities)
  defp get_author_name(o, %{"og" => %{"og:profile:first_name" => first_name, "profile:last_name" => last_name}}), do: Map.put(o, "author_name", "#{first_name} #{last_name}" |> Oginfo.Utils.remove_html_entities)
  defp get_author_name(o, %{"og" => %{"og:profile:username" => name}}), do: Map.put(o, "author_name", name |> Oginfo.Utils.remove_html_entities)
  defp get_author_name(o, %{"twitter" => %{"site" => name}}), do: Map.put(o, "author_name", name |> Oginfo.Utils.remove_html_entities)
  defp get_author_name(o, _), do: o

  #- Author URL
  defp get_author_url(o, %{"oembed" => %{"author_url" => url}}), do: Map.put(o, "author_url", url)
  defp get_author_url(o, %{"twitter" => %{"site" => url}}), do: Map.put(o, "author_url", "https://twitter.com/#{url}")
  defp get_author_url(o, _), do: o

  #- Provider name
  defp get_provider_name(o, %{"oembed" => %{"provider_name" => name}}), do: Map.put(o, "provider_name", name |> Oginfo.Utils.remove_html_entities)
  defp get_provider_name(o, %{"og" => %{"og:site_name" => name}}), do: Map.put(o, "provider_name", name |> Oginfo.Utils.remove_html_entities)
  defp get_provider_name(o, _), do: o

  #- Provider URL
  defp get_provider_url(o, %{"oembed" => %{"provider_url" => url}}), do: Map.put(o, "provider_url", url)
  defp get_provider_url(o, %{"og" => %{"og:url" => url}}), do: Map.put(o, "provider_url", Oginfo.Utils.base_url(url))
  defp get_provider_url(o, %{"meta" => %{"canonical" => url}}), do: Map.put(o, "provider_url", Oginfo.Utils.base_url(url))
  defp get_provider_url(o, %{"meta" => %{"url" => url}}), do: Map.put(o, "provider_url", Oginfo.Utils.base_url(url))
  defp get_provider_url(o, _), do: o

  #- URL
  defp get_url(o, %{"oembed" => %{"url" => url}}), do: Map.put(o, "url", url)
  defp get_url(o, %{"og" => %{"og:url" => url}}), do: Map.put(o, "url", url)
  defp get_url(o, %{"twitter" => %{"url" => url}}), do: Map.put(o, "url", url)
  defp get_url(o, %{"canonical" => %{"canonical" => url}}), do: Map.put(o, "url", url)
  defp get_url(o, %{"url" => url}), do: Map.put(o, "url", url)
  defp get_url(o, _), do: o

  #- Photo Width
  defp get_embed_width(o, %{"oembed" => %{"width" => width}}), do: Map.put(o, "thumbnail_width", Oginfo.Utils.string_to_integer("#{width}"))
  defp get_embed_width(o, %{"og" => %{"og:image:width" => width}}), do: Map.put(o, "thumbnail_width", Oginfo.Utils.string_to_integer("#{width}"))
  defp get_embed_width(o, _), do: o

  #- Photo Height
  defp get_embed_height(o, %{"oembed" => %{"height" => height}}), do: Map.put(o, "thumbnail_height", Oginfo.Utils.string_to_integer("#{height}"))
  defp get_embed_height(o, %{"og" => %{"og:image:height" => height}}), do: Map.put(o, "thumbnail_height", height)
  defp get_embed_height(o, _), do: o

  #- Thumbnail Url
  defp get_thumbnail_url(o, %{"oembed" => %{"thumbnail_url" => url}}), do: Map.put(o, "thumbnail_url", url)
  defp get_thumbnail_url(o, %{"og" => %{"og:image" => url}}), do: Map.put(o, "thumbnail_url", url)
  #- Need to fallback to biggest URL in content
  defp get_thumbnail_url(o, _), do: o

  #- Video
  defp get_video(o, %{"oembed" => %{"type" => "video", "html" => html, "width" => width, "height" => height}}) do
    o 
      |> Map.put("html", html)
      |> Map.put("type", "video")
      |> Map.put("width", Oginfo.Utils.string_to_integer("#{width}"))
      |> Map.put("height", Oginfo.Utils.string_to_integer("#{height}"))
  end
  defp get_video(o, _), do: o

  #- Get photo type
  defp get_photo(o, %{"oembed" => %{"type" => "photo", "width" => width, "height" => height, "url" => url}}) do
    o
      |> Map.put("type", "photo")
      |> Map.put("url", url)
      |> Map.put("width", Oginfo.Utils.string_to_integer("#{width}"))
      |> Map.put("height", Oginfo.Utils.string_to_integer("#{height}"))
  end
  defp get_photo(o, _), do: o

  #- Get rich type
  defp get_rich(o, %{"oembed" => %{"type" => "rich", "html" => html, "width" => width, "height" => height}}) do
    o 
      |> Map.put("html", html)
      |> Map.put("type", "rich")
      |> Map.put("width", Oginfo.Utils.string_to_integer("#{width}"))
      |> Map.put("height", Oginfo.Utils.string_to_integer("#{height}"))
  end
  defp get_rich(o, _), do: o

  #- Get domain 
  defp get_domain(o, _schema) do 
    Map.put(o, "provider_domain", Oginfo.Utils.domain(o["url"]))
  end
end
