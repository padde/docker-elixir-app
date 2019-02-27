defmodule AppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :app

  socket "/socket", AppWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :app,
    gzip: false,
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
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_app_key",
    signing_salt: "BWeTmQxT"

  plug AppWeb.Router

  def init(_type, config) do
    if config[:load_from_system_env] do
      port = String.to_integer(get_env!("PORT"))
      app_url = URI.parse(get_env!("APP_URL"))
      config =
        config
        |> Keyword.put(:http, [:inet6, port: port])
        |> Keyword.put(:url, [host: app_url.host, port: app_url.port])
        |> Keyword.put(:secret_key_base, get_env!("SECRET_KEY_BASE"))
      {:ok, config}
    else
      {:ok, config}
    end
  end

  defp get_env!(name) do
    System.get_env(name) || raise "expected the #{name} environment variable to be set"
  end
end
