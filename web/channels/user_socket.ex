defmodule Davo.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "users:*", Davo.UsersChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
    check_origin: false
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(%{"room" => room}, socket) do
    Task.start_link(fn ->
      :timer.sleep(1000)
      Davo.Repo.get_demo
      |> Enum.map(fn conn ->
        # From Troxy.PlugHelper
        plug = Davo.Troxy.Pipeline

        opts = plug.init([])
        method = conn.method |> String.downcase |> String.to_atom
        body_or_params = ""
        prepared_conn = Plug.Adapters.Test.Conn.conn(conn, method, conn.request_path, body_or_params)
        prepared_conn = %Plug.Conn{prepared_conn | port: conn.port, scheme: conn.scheme, peer: {{127, 0, 0, 2}, 111317}}


        prepared_conn
        |> plug.call(opts)
      end)
    end)
    {:ok, assign(socket, :room, room)}
  end

  def connect(_params, socket) do
    require Logger
    Logger.debug("connected!")
    {:ok, assign(socket, :room, "lobby")}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Davo.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
  # def id(socket), do: "users_socket:#{socket.assigns.room}"
end
