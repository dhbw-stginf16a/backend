defmodule BrettProjekt.Web.MainChannel do
  use Phoenix.Channel
  alias BrettProjekt.GameManager, as: GameManager
  alias BrettProjekt.Game, as: Game

  #@type game_id :: Game.game_id

  def join("main", _payload, socket) do
    {:ok, socket}
  end

  @type socket :: Elixir.Phoenix.Socket.t
  @type reply(msg) :: {:reply, msg, socket}

  #@spec handle_in(String.t, %{}, socket) :: reply({:ok, %{atom => game_id}})
  def handle_in("create_game", _payload, socket) do
    {:ok, _game, game_id} = GameManager.add_new_game :main_game_manager
    {:reply, {:ok, %{game_id: game_id}}, socket}
  end

  @spec handle_in(String.t, %{username: String.t, game_id: String.t}, socket) ::
    {:reply,
      {:ok, %{auth_token: String.t}} |
      {:error, %{error:
        :username_missing |
        :game_id_missing |
        :username_invalid |
        :game_id_invalid |
        :joining_disabled |
        :name_conflict
      }},
      socket
    }

  def handle_in("join_game", payload, socket) do
    cond do
      payload["username"] == nil ->
        {:reply, {:error, %{error: :username_missing}}, socket}
      payload["game_id"] == nil ->
        {:reply, {:error, %{error: :game_id_missing}}, socket}

      true ->
        # Request has all required fields, now check for validity
        name = Map.get(payload, "username")
        game_id = Map.get(payload, "game_id")
        game = GameManager.get_game_by_id(:main_game_manager, game_id)

        cond do
          not Game.name_valid?(name) ->
            {:reply, {:error, %{error: :username_invalid}}, socket}

          # Check whether a game with the specified game_id exists
          game == nil ->
            {:reply, {:error, %{error: :game_id_invalid}}, socket}

          # Username & game valid, add the user to the game
          # and create an auth_token
          true ->
            case Game.add_new_player(game, name) do
              {:error, :joining_disabled} ->
                {:reply, {:error, %{error: :joining_disabled}}, socket}

              {:error, :name_conflict} ->
                {:reply, {:error, %{error: :name_conflict}}, socket}

              {:ok, player_id} ->
                token = Phoenix.Token.sign(
                  BrettProjekt.Web.Endpoint,
                  "user_auth",
                  %{game_id: game_id, player_id: player_id}
                )

                {:reply, {:ok, %{
                  auth_token: token,
                  player_id: player_id,
                  team_count: 3 # TODO: Calculate team-count on the fly
                }}, socket}
            end
        end
    end
  end
end
