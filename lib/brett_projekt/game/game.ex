defmodule BrettProjekt.Game do
  alias __MODULE__, as: Game
  alias BrettProjekt.Game.LobbyStateTransformation, as: LobbyTrafo
  alias Game.RoundPreparation, as: RoundPrep

  @spec create(pos_integer) :: {:ok, pid}
  def create(team_count) do
    Agent.start_link(fn () -> Game.Lobby.create_game(team_count) end)
  end

  @type pure_function :: ((struct) -> pure_function_response)
  @type pure_function_response ::
    {:ok, struct} | {:ok, {struct, any}} | {:error, any}

  @spec apply_pure_function(Agent.agent, pure_function) ::
    {:ok, any} | {:error, any}
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

  @spec game_startable?(Agent.agent) :: {:ok, nil} | {:error, atom}
  def game_startable?(game) do
    apply_pure_function(game, fn state ->
      case LobbyTrafo.game_startable?(state) do

        {true, nil} -> {:ok, state}
        {false, error} -> {:error, error}
      end
    end)
  end

  def switch_team(game, player_id, team_id) do
    apply_pure_function(
      game, &(Game.Lobby.switch_team(&1, player_id, team_id)))
  end

  def add_new_player(game, name) do
    apply_pure_function(game, &(Game.Lobby.add_player(&1, name)))
  end

  def set_player_categories(game, player_id, category_ids) do
    case apply_pure_function(game,
          &(RoundPrep.set_player_categories(&1,player_id, category_ids))) do
      {:ok, nil} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  def get_lobby_update_broadcast(game) do
    {:ok, lobby} =
      apply_pure_function(game, &Game.Lobby.get_update_broadcast/1)
    lobby
  end

  @spec set_ready(Agent.agent, non_neg_integer, boolean) ::
    {:ok, nil} | {:error, :invalid_player_id}
  def set_ready(game, player_id, ready) do
    apply_pure_function(game, &(Game.Lobby.set_ready(&1, player_id, ready)))
  end

  @spec get_mode(Agent.agent) :: atom
  def get_mode(game) do
    game_state = Agent.get(game, &(&1))

    case Map.get(game_state, :__struct__) do
      Game.Lobby -> :lobby
      Game.RoundPreparation -> :round_preparation
      Game.Round -> :round
      Game.RoundEvaluation -> :round_evaluation
      Game.EndGame -> :game_end
    end
  end

  @spec start_game(Agent.agent) ::
    {:error, :not_everyone_ready} |
    {:error, :no_players} |
    {:error, :you_are_alone} |
    {:error, :missing_permission}
    {:ok, nil}
  def start_game(game) do
    apply_pure_function(game, &LobbyTrafo.transform/1)
  end

  def get_round_preparation_broadcast(game) do
    {:ok, prep} =
      apply_pure_function(game, &Game.RoundPreparation.get_broadcast/1)
    prep
  end

  def get_state(game) do
    {:ok, Agent.get(game, &(&1))}
  end
end
