defmodule BrettProjekt.Web.GameChannel do
  use Phoenix.Channel
  alias BrettProjekt.Game.Player, as: Player
  alias BrettProjekt.Game, as: Game
  alias BrettProjekt.GameManager, as: GameManager

  @doc """
  Check validity of `auth_token`.

  Check whether

  - `game_id`    is the same as the one in the `auth_token`
  - `auth_token` is not nil
  - `auth_token` has not expired
  - `auth_token` is not invalid

  ## Examples
      iex> game_id = "abc"
      iex> token = Phoenix.Token.sign(
               BrettProjekt.Web.Endpoint,
               "user_auth",
               %{game_id: game_id, player_id: 1}
           )
      iex> BrettProjekt.Web.GameChannel.auth_token_valid? token, game_id
  """
  def check_auth_token(auth_token, game_id) do
    verification = Phoenix.Token.verify(BrettProjekt.Web.Endpoint,
                                        "user_auth", auth_token)
    case verification do
      {:ok, %{game_id: ^game_id} = payload} ->
        game = GameManager.get_game_by_id :main_game_manager, payload[:game_id]
        player = Game.get_player game, payload[:player_id]
        {:ok, payload, game, player}
      # Client shouldn't know game_id is valid for another game
      {:ok, _payload}                       -> {:error, :auth_token_invalid}
      {:error, :missing}                    -> {:error, :auth_token_missing}
      {:error, :expired}                    -> {:error, :auth_token_invalid}
      {:error, :invalid}                    -> {:error, :auth_token_invalid}
    end
  end

  @doc """
  Join the channel of a particular game.

  `payload` has to contain an "auth_token" valid for the `socket`

  ## Returns
  - {:ok, socket}
  - {:error, msg} msg is an error code from `auth_token_valid`
  """
  def join(channel, payload, socket) do
    game_id = String.replace_prefix channel, "game:", ""
    case check_auth_token(payload["auth_token"], game_id) do
      {:ok, _token_payload, _, _} -> {:ok, assign(socket, :game_id, game_id)}
      {:error, msg}               -> {:error, %{reason: msg}}
    end
  end

  @doc """
  Sets the team membership of the user with the "auth_token" in the payload.
  Broadcasts a lobby_update to all users in this game/channel.

  ## Returns
  - {:reply, :ok, socket}
  - {:reply, {:error, %{reason: :empty_team}}, socket}
  - {:reply, {:error, %{reason: auth_token_invalid}}, socket}
  - {:reply, {:error, %{reason: auth_token_missing}}, socket}

  """
  def handle_in("set_categories", %{"team" => ""}, socket) do
    {:reply, {:error, %{reason: :empty_team}}, socket}
  end
  def handle_in("set_team", payload, socket) do
    case check_auth_token(payload["auth_token"], socket.assigns[:game_id]) do
      {:ok, _token_payload, game, player} ->
        Player.set_team player, payload["team"]

        broadcast_lobby_update socket, game
        {:reply, :ok, socket}

      {:error, msg} -> {:reply, {:error, %{reason: msg}}, socket}
    end
  end

  @doc """
  ## Returns
  - {:reply, :ok, socket}
  - {:reply, {:error, %{reason: msg}}, socket}
  - {:reply, {:error, %{reason: :auth_token_invalid}}, socket}
  - {:reply, {:error, %{reason: :auth_token_missing}}, socket}
  - {:reply, {:error, %{reason: :categories_unavailable}}, socket}
  - {:reply, {:error, %{reason: :categories_missing}}, socket}
  - {:reply, {:error, %{reason: :categories_empty}}, socket}
  """
  def handle_in("set_categories", %{"categories" => []}, socket) do
    {:reply, {:error, %{reason: :categories_empty}}, socket}
  end
  def handle_in("set_categories", %{"categories" => _categories} = payload, socket) do
    case check_auth_token(payload["auth_token"], socket.assigns[:game_id]) do
      {:ok, _token_payload, game, player} ->
        case Game.set_player_categories(game, player, payload["categories"]) do
          :ok ->
            broadcast_round_preparation socket, game
            {:reply, :ok, socket}
          {:error, :categories_unavailable} ->
            {:reply, {:error, %{reason: :categories_unavailable}}, socket}
        end
      {:error, msg} -> {:reply, {:error, %{reason: msg}}, socket}
    end
  end
  def handle_in("set_categories", _payload, socket) do
    {:reply, {:error, %{reason: :categories_missing}}, socket}
  end

  @doc """
  Send a broadcast to all users in this game/channel with the updated
  list of players and startable status of the game.
  """
  def broadcast_lobby_update(socket, game) do
    players = game
      |> Game.get_players
      |> Enum.map(fn({_id, player}) ->
        %{
          id: Player.get_id(player),
          name: Player.get_name(player),
          team: Player.get_team(player),
          roles: Player.get_roles(player)
        }
      end)
    broadcast(socket, "lobby_update", %{
      max_teams: 3,
      startable: Game.startable?(game),
      players: players
    })
  end

  def broadcast_round_preparation(socket, game) do
    players = game
      |> Game.get_players
      |> Enum.map(fn({_id, player}) ->
        %{
          id: Player.get_id(player),
          name: Player.get_name(player),
          team: Player.get_team(player),
          roles: Player.get_roles(player),
          categories: Game.get_player_categories(game, player)
        }
      end)
    broadcast(socket, "round_preparation", %{
      round_started: Game.round_started?(game),
      categories: Game.get_categories(game),
      players: players
    })
  end
end
