defmodule BrettProjekt.GameManager do
  use GenServer
  alias BrettProjekt.Game, as: Game

  # ---------- CLIENT API ----------
  def start_link do
    start_link(nil)
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{ games: %{}, game_ids: [] }, name: name)
  end

  def add_new_game(game_manager) do
    {:ok, game} = Game.create generate_game_id game_manager
    add_game game_manager, game
  end

  def add_game(game_manager, game) do
    GenServer.call(game_manager, {:add_game, game})
  end

  def generate_game_id(game_manager) do
    GenServer.call(game_manager, :generate_game_id)
  end

  def get_games(game_manager) do
    GenServer.call(game_manager, :get_games)
  end

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
