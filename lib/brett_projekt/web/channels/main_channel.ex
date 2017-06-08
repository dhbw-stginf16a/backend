defmodule BrettProjekt.Web.MainChannel do
  use Phoenix.Channel
  alias BrettProjekt.GameManager, as: GameManager
  alias BrettProjekt.Game, as: Game

  def join("main", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("create_game", _payload, socket) do
    {:ok, game_id, _game} = GameManager.add_new_game :main_game_manager
    {:reply, {:ok, %{game_id: game_id}}, socket}
  end

  def handle_in("join_game", payload, socket) do
    cond do
      Map.get(payload, "username") == nil ->
        {:reply, {:err, %{error: "invalid_request"}}, socket}
      Map.get(payload, "game_id") == nil ->
        {:reply, {:err, %{error: "invalid_request"}}, socket}

      true ->
        # Request has all required fields, now check for validity
        name = Map.get payload, "username"
        game_id = Map.get payload, "game_id"
        game = GameManager.get_game_by_id :main_game_manager, game_id

        cond do
          # Check whether the username is a printable string and is between 3 and 8 characters
          (not is_binary name) or
          (not String.printable? name) or
          (String.length(name) < 3) or
          (String.length(name) > 8) ->
            {:reply, {:err, %{error: "username_invalid"}}, socket}

          # Check whether a game with the specified game_id exists
          game == nil ->
            {:reply, {:err, %{error: "game_id_invalid"}}, socket}

          # Username & game valid, add the user to the game and create an auth_token
          true ->
            case Game.add_new_player game, name do
              {:err, :joining_disabled} ->
                {:reply, {:err, %{error: "joining_disabled"}}, socket}

              {:err, :name_conflict} ->
                {:reply, {:err, %{error: "name_conflict"}}, socket}

              {:ok, player, _player} ->
                player_id = BrettProjekt.Game.Player.get_id player

                token = Phoenix.Token.sign(
                  BrettProjekt.Web.Endpoint,
                  "user_auth",
                  %{game_id: game_id, player_id: player_id}
                )

                {:reply, {:ok, %{auth_token: token}}, socket}
            end
        end
    end
  end
end
