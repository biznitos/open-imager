defmodule Oginfo.Og do

  # http://ogp.me

  def parse(schema) do
    %{"version" => "0.9"}
      |> get_type(schema)
      |> get_title(schema)
      |> get_description(schema)
      |> get_url(schema)
      |> get_thumbnail_url(schema)
      |> get_determiner(schema)
      |> get_locale(schema)
      |> get_provider_name(schema)
      |> get_provider_url(schema)
      |> get_video(schema)
      |> get_video_secure_url(schema)
      |> get_image_url(schema)
      |> get_image_secure_url(schema)
      |> get_image_type(schema)
      |> get_embed_width(schema)
      |> get_embed_height(schema)
      |> get_video_type(schema)
      |> get_video_height(schema)
      |> get_video_width(schema)
      |> get_audio_url(schema)
      |> get_audio_secure_url(schema)
      |> get_audio_type(schema)
      |> missing_fields(schema)
      |> get_locale(schema)
      |> get_brand(schema)
      |> get_currency(schema)
      |> get_price(schema)
  end

  #- Provider URL
  defp get_provider_url(o, %{"oembed" => %{"provider_url" => url}}), do: Map.put(o, "site_url", url)
  defp get_provider_url(o, %{"og" => %{"og:url" => url}}), do: Map.put(o, "site_url", Oginfo.Utils.base_url(url))
  defp get_provider_url(o, %{"meta" => %{"canonical" => url}}), do: Map.put(o, "site_url", Oginfo.Utils.base_url(url))
  defp get_provider_url(o, %{"meta" => %{"url" => url}}), do: Map.put(o, "site_url", Oginfo.Utils.base_url(url))
  defp get_provider_url(o, _), do: o

  defp get_locale(o, %{"og" => %{"og:locale" => locale}}), do: Map.put(o, "locale", locale |> Oginfo.Utils.remove_html_entities)
  defp get_locale(o, _), do: Map.put(o, "locale", "en")

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
  defp get_title(o, %{"og" => %{"title" => title}}), do: Map.put(o, "title", title |> Oginfo.Utils.remove_html_entities)
  defp get_title(o, %{"oembed" => %{"title" => title}}), do: Map.put(o, "title", title |> Oginfo.Utils.remove_html_entities)
  defp get_title(o, %{"twitter" => %{"title" => title}}), do: Map.put(o, "title", title |> Oginfo.Utils.remove_html_entities)
  defp get_title(o, %{"native" => %{"title" => title}}), do: Map.put(o, "title", title |> Oginfo.Utils.remove_html_entities) 
  defp get_title(o, _), do: o

  #- Figure out description
  defp get_description(o, %{"og" => %{"og:description" => desc}}), do: Map.put(o, "description", desc |> Oginfo.Utils.remove_html_entities |> HtmlSanitizeEx.strip_tags())
  defp get_description(o, %{"oembed" => %{"description" => desc}}), do: Map.put(o, "description", desc |> Oginfo.Utils.remove_html_entities |> HtmlSanitizeEx.strip_tags())
  defp get_description(o, %{"native" => %{"description" => desc}}), do: Map.put(o, "description", desc |> Oginfo.Utils.remove_html_entities |> HtmlSanitizeEx.strip_tags())
  defp get_description(o, _), do: Map.put(o, "description", nil)

  #- URL
  defp get_url(o, %{"og" => %{"og:url" => url}}), do: Map.put(o, "url", url)
  defp get_url(o, %{"oembed" => %{"url" => url}}), do: Map.put(o, "url", url)
  defp get_url(o, %{"twitter" => %{"url" => url}}), do: Map.put(o, "url", url)
  defp get_url(o, %{"canonical" => %{"canonical" => url}}), do: Map.put(o, "url", url)
  defp get_url(o, %{"url" => url}), do: Map.put(o, "url", url)
  defp get_url(o, _), do: o

  #- Image
  defp get_thumbnail_url(o, %{"og" => %{"og:image" => url}}), do: Map.put(o, "image", url)
  defp get_thumbnail_url(o, %{"oembed" => %{"thumbnail_url" => url}}), do: Map.put(o, "image", url)
  #- Need to fallback to biggest URL in content
  defp get_thumbnail_url(o, _), do: o

  #- Determiner
  defp get_determiner(o, %{"og" => %{"og:determiner" => det}}), do: Map.put(o, "determiner", det)
  defp get_determiner(o, _), do: o

  #- Site name
  defp get_provider_name(o, %{"og" => %{"og:site_name" => name}}), do: Map.put(o, "site_name", name)
  defp get_provider_name(o, %{"oembed" => %{"provider_name" => name}}), do: Map.put(o, "site_name", name)
  defp get_provider_name(o, _), do: o

  #- Video url
  defp get_video(o, %{"og" => %{"og:video" => url}}), do: Map.put(o, "video", url)
  defp get_video(o, _), do: o

  #- Video secure url
  defp get_video_secure_url(o, %{"og" => %{"og:video:secure_url" => url}}), do: Map.put(o, "video:secure_url", url)
  defp get_video_secure_url(o, _), do: o

  #- Image urls
  defp get_image_url(o, %{"og" => %{"og:image:url" => url}}), do: Map.put(o, "image:url", url)
  defp get_image_url(o, _), do: o

  #- Image secure url
  defp get_image_secure_url(o, %{"og" => %{"og:image:secure_url" => url}}), do: Map.put(o, "image:secure_url", url)
  defp get_image_secure_url(o, _), do: o

  #- Image type
  defp get_image_type(o, %{"og" => %{"og:image:type" => type}}), do: Map.put(o, "image:type", type)
  defp get_image_type(%{"image" => image} = o, _) do 
    mime_type =
      image
        |> Path.extname
        |> String.trim
        |> String.replace(~r/^\./, "")
        |> String.trim
        |> String.downcase
        |> MIME.type
    Map.put(o, "image:type", mime_type)     
  end
  defp get_image_type(o, _), do: o

  #- Photo Width
  defp get_embed_width(o, %{"og" => %{"og:image:width" => width}}), do: Map.put(o, "image:width", Oginfo.Utils.string_to_integer("#{width}"))
  defp get_embed_width(o, %{"oembed" => %{"width" => width}}), do: Map.put(o, "image:width", Oginfo.Utils.string_to_integer("#{width}"))
  defp get_embed_width(o, _), do: o

  #- Photo Height
  defp get_embed_height(o, %{"og" => %{"og:image:height" => height}}), do: Map.put(o, "image:height", height)
  defp get_embed_height(o, %{"oembed" => %{"height" => height}}), do: Map.put(o, "image:height", Oginfo.Utils.string_to_integer("#{height}"))
  defp get_embed_height(o, _), do: o

  #- Video type
  defp get_video_type(o, %{"og" => %{"og:video:type" => type}}), do: Map.put(o, "video:type", type)
  defp get_video_type(%{"video" => image} = o, _) do 
    mime_type =
      image
        |> Path.extname
        |> String.trim
        |> String.replace(~r/^\./, "")
        |> String.trim
        |> String.downcase
        |> MIME.type
    Map.put(o, "video:type", mime_type)     
  end
  defp get_video_type(o, _), do: o

  #- Video Width
  defp get_video_width(o, %{"og" => %{"og:video:width" => width}}), do: Map.put(o, "video:width", Oginfo.Utils.string_to_integer("#{width}"))
  defp get_video_width(o, %{"oembed" => %{"width" => width, "type" => "video"}}), do: Map.put(o, "video:width", Oginfo.Utils.string_to_integer("#{width}"))
  defp get_video_width(o, _), do: o

  #- Photo Height
  defp get_video_height(o, %{"og" => %{"og:video:height" => height}}), do: Map.put(o, "video:height", Oginfo.Utils.string_to_integer("#{height}"))
  defp get_video_height(o, %{"oembed" => %{"height" => height, "type" => "video"}}), do: Map.put(o, "video:height", Oginfo.Utils.string_to_integer("#{height}"))
  defp get_video_height(o, _), do: o

  #- Audio URL
  defp get_audio_url(o, %{"og" => %{"og:audio" => url}}), do: Map.put(o, "audio", url)
  defp get_audio_url(o, _), do: o

  #- Audio secure url
  defp get_audio_secure_url(o, %{"og" => %{"og:audio:secure_url" => url}}), do: Map.put(o, "audio:secure_url", url)
  defp get_audio_secure_url(o, _), do: o

  defp get_audio_type(o, %{"og" => %{"og:audio:type" => type}}), do: Map.put(o, "image:type", type)
  defp get_audio_type(%{"audio" => image} = o, _) do 
    mime_type =
      image
        |> Path.extname
        |> String.trim
        |> String.replace(~r/^\./, "")
        |> String.trim
        |> String.downcase
        |> MIME.type
    Map.put(o, "audio:type", mime_type)     
  end
  defp get_audio_type(o, _), do: o

  #- Include all other types we don't already have
  defp missing_fields(o, %{"og" => og}) do
    og2 = 
      Enum.map(og, fn {k,v} -> {String.replace(k, ~r/^og:/, ""), v} end) 
        |> Enum.into(%{}) 
    Map.merge(og2, o)
  end
  defp missing_fields(o, _), do: o


end
