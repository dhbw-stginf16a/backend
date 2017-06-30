defmodule BrettProjekt.Web.GameChannel do
  use Phoenix.Channel
  alias BrettProjekt.GameManager, as: GameManager
  alias BrettProjekt.Game, as: Game

  @spec auth_token_valid?(String.t, GameManager.game_id) ::
    {:ok, struct} |
    {:error, :auth_token_invalid} |
    {:error, :auth_token_missing}
  def auth_token_valid?(auth_token, game_id) do
    verification = Phoenix.Token.verify(BrettProjekt.Web.Endpoint,
                                        "user_auth", auth_token)
    case verification do
      {:ok, %{game_id: ^game_id} = payload} -> {:ok, payload}
      # Client shouldn't know game_id is valid for another game
      {:ok, _payload}                       -> {:error, :auth_token_invalid}
      {:error, :missing}                    -> {:error, :auth_token_missing}
      {:error, :expired}                    -> {:error, :auth_token_invalid}
      {:error, :invalid}                    -> {:error, :auth_token_invalid}
    end
  end

  @spec join(String.t, map, Phoenix.Socket.t) ::
    {:ok, Phoenix.Socket.t} |
    {:ok, map, Phoenix.Socket.t} |
    {:error, %{reason: any}}
  def join(channel, payload, socket) do
    game_id = String.replace_prefix channel, "game:", ""
    case auth_token_valid?(payload["auth_token"], game_id) do
      {:ok, _token_payload} -> {:ok, assign(socket, :game_id, game_id)}
      {:error, msg}         -> {:error, %{reason: msg}}
    end
  end

  @spec handle_in(String.t, map, Phoenix.Socket.t) ::
    {:reply,
      :ok | {:error, %{reason: :auth_token_invalid | :auth_token_missing}},
      Phoenix.Socket.t}
  def handle_in("trigger_lobby_update", payload, socket) do
    case auth_token_valid?(payload["auth_token"], socket.assigns[:game_id]) do
      {:ok, token_payload} ->
        game = GameManager.get_game_by_id(:main_game_manager,
                                          token_payload.game_id)

        broadcast_lobby_update(socket, game)
        {:reply, :ok, socket}
      {:error, msg} -> {:reply, {:error, %{reason: msg}}, socket}
    end
  end

  @spec handle_in(String.t, map, Phoenix.Socket.t) ::
    {:reply,
      :ok | {:error, %{reason:
        :team_invalid |
        :auth_token_invalid |
        :auth_token_missing
      }},
      Phoenix.Socket.t}
  def handle_in("set_team", payload, socket) do
    case auth_token_valid?(payload["auth_token"], socket.assigns[:game_id]) do
      {:ok, token_payload} ->
        game = GameManager.get_game_by_id(:main_game_manager,
                                          token_payload.game_id)

        team_id = payload["team"]
        player_id = token_payload.player_id
        case Game.switch_team(game, player_id, team_id) do
          {:ok, _} ->
            broadcast_lobby_update(socket, game)
            {:reply, :ok, socket}
          {:error, :team_invalid} ->
            {:reply, {:error, %{reason: :team_invalid}}, socket}
        end
      {:error, msg} -> {:reply, {:error, %{reason: msg}}, socket}
    end
  end

  @spec handle_in(String.t, map, Phoenix.Socket.t) ::
    {:reply,
      :ok | {:error, %{reason:
        :auth_token_invalid |
        :auth_token_missing
      }},
      Phoenix.Socket.t}
  def handle_in("set_ready", payload, socket) do
    case auth_token_valid?(payload["auth_token"], socket.assigns[:game_id]) do
      {:ok, token_payload} ->
        game = GameManager.get_game_by_id(:main_game_manager,
                                          token_payload.game_id)

        player_id = token_payload.player_id
        player_ready = payload["ready"] == true
        Game.set_ready(game, player_id, player_ready)

        broadcast_lobby_update(socket, game)
        {:reply, :ok, socket}

      {:error, msg} ->
        {:reply, {:error, %{reason: msg}}, socket}
    end
  end

  @spec handle_in(String.t, map, Phoenix.Socket.t) ::
    {:reply,
      :ok | {:error, %{reason:
        :game_not_startable |
        :missing_permission |
        :auth_token_invalid |
        :auth_token_missing
      }},
      Phoenix.Socket.t}
  def handle_in("start_game", payload, socket) do
    case auth_token_valid?(payload["auth_token"], socket.assigns[:game_id]) do
      {:ok, token_payload} ->
        game = GameManager.get_game_by_id(:main_game_manager,
                                          token_payload.game_id)
        player_id = token_payload.player_id
        {:ok, startable} = Game.game_startable?(game)
        cond do
          not startable ->
            {:reply, {:error, %{reason: :game_not_startable}}, socket}
          player_id == 0 ->
            {:reply, {:error, %{reason: :missing_permission}}, socket}
          true ->
            nil
        end
      {:error, msg} -> {:reply, {:error, %{reason: msg}}, socket}
    end
  end

  def broadcast_lobby_update(socket, game) do
    struct = Game.get_lobby_update_broadcast(game)
    broadcast!(socket, "lobby_update", struct)
  end
end
