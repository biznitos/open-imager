# TAT Imager

This service mimics the most important parts of the imgix service and hosts images itself

Requirements:

  * Docker
  * ImageMagick
  * Some space on a volume on your server

## Getting Started

## Create an Endpoint

You must create an endpoint for your images in any of your config/[config|dev|prod].exs file

```yaml
config :app, :imager,
  endpoints: %{
    "images.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    "cdn1.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    "cdn2.gttwl.net" => %{url: "https://gttwl.s3.amazonaws.com", storage: "/tmp/gttwl"},
    ...
  }
```

## Change your image paths

  **Change this:**

  "https://gttwl.s3.amazonaws.com/attachments/v4/71314/cc788588-c316-43e3-ae85-c08ee41dcaa3.jpeg"

  **To this:**

  "https://images.gttwl.net/uploads/71314/cc788588-c316-43e3-ae85-c08ee41dcaa3.jpeg"

## Parameters to control imaging

  * **w** - Width of the image (optional, but must have w or h)
  * **h** - Height of the image (optional, but must have w or h)
  * **q** - Quality, 10-100 percent
  * **auto** - Can be one of [enhance|sharpen|contrast]
  * **fm** - Format, can be one of [jpeg|png|webp|gif] - default jpeg
  * **dpr** - Display density [1-8] 1 = 72, 2 = 144, etc

  Example:

  "https://images.gttwl.net/uploads/71314/cc788588-c316-43e3-ae85-c08ee41dcaa3.jpeg?w=640&h=480&auto=enhance"

## Use the API with images from anywhere

  "https://images.gttwl.net/v1/image?w=100&h=100&url=[https://mysite.com/hello.png]

# Other services

  **Oembed data from any url**
  
  "https://images.gttwl.net/v1/oembed?url=https://www.youtube.com/watch=28734jhjg

  **Open Graph Data from any url**
  
  "https://images.gttwl.net/v1/og?url=https://www.youtube.com/watch=28734jhjg

  **Raw parsed Data from any url**

  "https://images.gttwl.net/v1/raw?url=https://www.youtube.com/watch=28734jhjg

