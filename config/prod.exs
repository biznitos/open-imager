use Mix.Config

config :app, AppWeb.Endpoint,
  http: [port: 3009, ip: {0,0,0,0}],
  url: [host: "extname.com", port: 3009],
  secret_key_base: "8K0rBpRtftqxym6KETZELvBi3yR355w7ma7PZc0LuYV1X3761I8cDwk0IRrFtkog",
  server: true,
  root: ".",
  version: Application.spec(:phoenix_distillery, :vsn)

