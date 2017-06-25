defmodule BrettProjekt.GameManager do
  alias BrettProjekt.Game, as: Game

  @team_count 3
  @hashids_salt "myfancysalt"
  @type game :: pid
  @type game_id :: String.t

  @moduledoc """
  Provides state and functions for handling Game instances.

  The GameManager is implemented as an Agent holding different Game instances.
  These can be accessed by convenient functions.

  It also provides functions for generating unique game-identifiers.
  """

  # ---------- CLIENT API ----------
  @doc """
  Starts a new GameManager instance

  The Agent will be started with no name assigned.

  ## Example

      {:ok, game_manager} = BrettProject.GameManager.start_link

  """
  def start_link do
    start_link nil
  end

  @doc """
  Starts a new GameManager instance with a name assigned

  ## Arguments

    - name: Name of the GameManager (as an Atom)

  ## Examples

      {:ok, game_manager} = BrettProjekt.GameManager.start_link :my_fancy_game_manager

  """
  def start_link(name) do
    Agent.start_link(fn () ->
      %{
        games: %{},
        game_id_counter: 0,
        hashids: Hashids.new(salt: @hashids_salt)}
    end, name: name)
  end

  @doc """
  Creates a `BrettProjekt.Game` and adds it to the GameManager

  A unique game-id will automatically be generated.

  ## Examples

      iex> {:ok, game_manager} = BrettProjekt.GameManager.start_link
      iex> {:ok, _game_id, game} = BrettProjekt.GameManager.add_new_game game_manager
      iex> is_pid game
      true

  """
  @spec add_new_game(Agent.agent) :: {:ok, game, game_id}
  def add_new_game(game_manager) do
    {:ok, game} = Game.create @team_count
    game_id = get_new_game_id(game_manager)
    :ok = add_game(game_manager, game, game_id)
    {:ok, game, game_id}
  end

  defp add_game(game_manager, game, game_id) do
    Agent.update(game_manager, fn state ->
      %{state | games: Map.put(state.games, game_id, game)}
    end)
  end

  defp get_new_game_id(game_manager) do
    {current_id, hashids} =
      Agent.get_and_update(game_manager,
                           fn %{game_id_counter: id_count} = state ->
        {{id_count, state.hashids}, %{state | game_id_counter: id_count + 1}}
      end)

    Hashids.encode(hashids, [current_id])
  end
end
