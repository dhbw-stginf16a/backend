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

  @doc """
  Join the channel of a particular game.

  `payload` has to contain an "auth_token" valid for the `socket`

  ## Returns
  - {:ok, socket}
  - {:error, msg} msg is an error code from `auth_token_valid`
  """
  def join(channel, payload, socket) do
    game_id = String.replace_prefix channel, "game:", ""
    case auth_token_valid?(payload["auth_token"], game_id) do
      {:ok, _token_payload} -> {:ok, assign(socket, :game_id, game_id)}
      {:error, msg}        -> {:error, %{reason: msg}}
    end
  end

  @doc """
  Creates a new game and returns its id.

  ## Returns
  {:reply, {:ok, %{game_id: game_id}}, socket}
  """
  def handle_in("create_game", _payload, socket) do
    {:ok, game_id, _game} = GameManager.add_new_game :main_game_manager
    {:reply, {:ok, %{game_id: game_id}}, socket}
  end

  @doc """
  Sets the team membership of the user with the "auth_token" in the payload.
  Broadcasts a lobby_update to all users in this game/channel.

  ## Returns
  - {:reply, :ok, socket}
  - {:reply, {:error, %{reason: :empty_team}}, socket}
  - {:reply, {:error, %{reason: msg}}, socket}

  """
  def handle_in("set_categories", %{"team" => ""}, socket) do
    {:reply, {:error, %{reason: :empty_team}}, socket}
  end
  def handle_in("set_team", payload, socket) do
    case auth_token_valid?(payload["auth_token"], socket.assigns[:game_id]) do
      {:ok, token_payload} ->
        game = GameManager.get_game_by_id(:main_game_manager,
                                          token_payload.game_id)

        game
        |> Game.get_players
        |> Map.get(token_payload.player_id)
        |> Player.set_team(payload["team"])

        broadcast_lobby_update socket, game
        {:reply, :ok, socket}

      {:error, msg} -> {:reply, {:error, %{reason: msg}}, socket}
    end
  end

  @doc """
  ## Returns
  - {:reply, :ok, socket}
  - {:reply, {:error, %{reason: :categories_unavailable}}, socket}
  - {:reply, {:error, %{reason: msg}}, socket}
  """
  def handle_in("set_categories", %{"categories" => []}, socket) do
    {:reply, {:error, %{reason: :empty_categories}}, socket}
  end
  def handle_in("set_categories", payload, socket) do
    case auth_token_valid?(payload["auth_token"], socket.assigns[:game_id]) do
      {:ok, token_payload} ->
        categories = payload["categories"]
        game = GameManager.get_game_by_id(:main_game_manager,
                                          token_payload.game_id)

        categories_available =
          game
          |> Game.get_categories
          |> MapSet.new
          |> (&MapSet.subset?(MapSet.new(categories), &1)).()
        unless categories_available do
          {:reply, {:error, %{reason: :categories_unavailable}}, socket}
        else
          game
          |> Game.get_players
          |> Map.get(token_payload.player_id)
          |> Player.set_categories(categories)

          broadcast_round_preparation socket, game
          {:reply, :ok, socket}
        end
      {:error, msg} -> {:reply, {:error, %{reason: msg}}, socket}
    end
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
          categories: Player.get_categories(player)
        }
      end)
    broadcast(socket, "round_preparation", %{
      round_started: Game.round_started?(game),
      categories: Game.get_categories(game),
      players: players
    })
  end
end
