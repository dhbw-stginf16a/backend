defmodule BrettProjekt.GameManager do
  use GenServer
  alias BrettProjekt.Game, as: Game

  @moduledoc """
  Provides state and functions for handling Game instances.

  The GameManager is implemented as a GenServer holding different Game instances.
  These can be accessed by convenient functions.

  It also provides functions for generating unique game-identifiers.
  """

  # ---------- CLIENT API ----------
  @doc """
  Starts a new GameManager instance

  The GenServer will be started with no name assigned.

  ## Example

      {:ok, game_manager} = BrettProject.GameManager.start_link

  """
  def start_link do
    start_link(nil)
  end

  @doc """
  Starts a new GameManager instance with a name assigned

  ## Arguments

    - name: Name of the GameManager (as an Atom)

  ## Examples

      {:ok, game_manager} = BrettProjekt.GameManager.start_link :my_fancy_game_manager

  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, %{ games: %{}, game_ids: [] }, name: name)
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
  def add_new_game(game_manager) do
    {:ok, game} = Game.create generate_game_id game_manager
    add_game game_manager, game
  end

  @doc """
  Adds an existing `BrettProjekt.Game` to the GameManager

  The `BrettProjekt.Game` needs to have a unique id already set.
  Get it form `generate_game_id/1`.

  ## Examples

      iex> {:ok, game_manager} = BrettProjekt.GameManager.start_link
      iex> {:ok, game} = BrettProjekt.Game.create(BrettProjekt.GameManager.generate_game_id game_manager)
      iex> {:ok, game_id, ^game} = BrettProjekt.GameManager.add_game game_manager, game
      iex> is_binary game_id
      true

  """
  def add_game(game_manager, game) do
    GenServer.call(game_manager, {:add_game, game})
  end

  @doc """
  Generates a unique game-id string

  The resulting string will be a Base-32 encoded 6-character long string.
  """
  def generate_game_id(game_manager) do
    GenServer.call(game_manager, :generate_game_id)
  end

  @doc """
  Returns a map of registered games

  The resulting map has game-ids as keys and game-pids as values.
  """
  def get_games(game_manager) do
    GenServer.call(game_manager, :get_games)
  end

  @doc """
  Finds a game by id

  Returns `nil` no game with given id is registered.

  ## Arguments

    - game_manager: The game_manager to search on
    - game_id: The game_id to search for

  ## Example

      iex> {:ok, game_manager} = BrettProjekt.GameManager.start_link
      iex> {:ok, game_id, _} = BrettProjekt.GameManager.add_new_game game_manager
      iex> game1 = BrettProjekt.GameManager.get_game_by_id game_manager, game_id
      iex> is_pid game1
      true
      iex> game2 = BrettProjekt.GameManager.get_game_by_id game_manager, "foobar"
      iex> is_nil game2
      true

  """
  def get_game_by_id(game_manager, game_id) do
    GenServer.call(game_manager, {:get_game_by_id, game_id})
  end

  # ---------- SERVER API ----------
  defp random_game_id() do
    game_id_length = 6

    time_str = to_string :os.system_time(:millisecond)
    unique_int_str = to_string System.unique_integer
    hash = :crypto.hash(:md5, time_str <> unique_int_str)
           |> Base.encode32(case: :upper, padding: false)

    String.slice hash, 0..game_id_length
  end

  def handle_call(:generate_game_id, from, %{game_ids: game_ids} = state) do
    # Depending on length high chance of collision, so check below
    game_id = random_game_id()

    case Enum.member? game_ids, game_id do
      false ->
        new_state = %{ state | game_ids: [game_id | game_ids] }
        {:reply, game_id, new_state}
      true ->
        handle_call(:generate_game_id, from, state)
    end
  end

  def handle_call({:add_game, game}, _from, %{ games: games } = state) do
    game_id = Game.get_id game

    case Map.get(games, game_id) do
      nil ->
        new_state = %{ state | games: Map.put(games, game_id, game) }
        {:reply, {:ok, game_id, game}, new_state}
      _ ->
        {:reply, {:err, :game_already_registered}, state}
    end
  end

  def handle_call(:get_games, _from, %{ games: games } = state) do
    {:reply, games, state}
  end

  def handle_call({:get_game_by_id, game_id}, _from, %{ games: games } = state) do
    {:reply, Map.get(games, game_id, nil), state}
  end
end
