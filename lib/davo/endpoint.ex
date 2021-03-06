defmodule Davo.CORS do
  use Corsica.Router,
    max_age: 600,
    allow_credentials: true,
    allow_headers: ~w(x-troxy-host),
    origins: "*"

  resource "/*"
end

defmodule Davo.Endpoint do
  use Phoenix.Endpoint, otp_app: :davo
  plug Davo.CORS
  plug Davo.Troxy.Pipeline

  socket "/socket", Davo.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :davo, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_davo_key",
    signing_salt: "N5AJfQjg"

  plug Davo.Router
end
