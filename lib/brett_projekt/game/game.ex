defmodule BrettProjekt.Game do
  alias __MODULE__, as: Game

  @spec create(pos_integer) :: {:ok, pid}
  def create(team_count) do
    Agent.start_link(fn () -> Game.Lobby.create_game(team_count) end)
  end

  @type pure_function :: ((struct) -> pure_function_response)
  @type pure_function_response ::
    {:ok, struct} | {:ok, {struct, any}} | {:error, any}

  @spec apply_pure_function(Agent.agent, pure_function) ::
    {:ok, {struct, any}} | {:ok, struct} | {:error, any}
  def apply_pure_function(game, pure_function) do
    result =
      Agent.get_and_update(game, fn state ->
        case pure_function.(state) do
          {:ok, {new_state, msg}} ->
            {{:ok, msg}, new_state}
          {:ok, new_state} ->
            {:ok, new_state}
          {:error, error} ->
            {{:error, error}, state}
        end
      end)
    case result do
      :ok -> {:ok, nil}
      _   -> result
    end
  end

  # Check whether the username is a printable string
  # and is between 3 and 8 characters long
  def name_valid?(name) do
    cond do
      is_binary(name) == false         -> false
      String.printable?(name) == false -> false
      String.length(name) < 3          -> false
      String.length(name) > 12         -> false
      true 									           -> true
    end
  end

  defp join_enabled?(game_state) do
    true
  end

  defp has_player?(game_state, name) do
    false
  end

  def game_startable?(game) do
    false
  end

  def switch_team(game, player_id, team_id) do
    apply_pure_function(
      game, &(Game.Lobby.switch_team(&1, player_id, team_id)))
  end

  def add_new_player(game, name) do
    apply_pure_function(game, &(Game.Lobby.add_player(&1, name)))
  end

  def get_lobby_update_broadcast(game) do
    {:ok, lobby} =
      apply_pure_function(game, &Game.Lobby.get_update_broadcast/1)
    lobby
  end
end
