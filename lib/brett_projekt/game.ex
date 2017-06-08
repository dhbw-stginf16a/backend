

defmodule BrettProjekt.Game.Player do
  defstruct [
    :id,
    :name,
    {:roles, []}
  ]
end

defmodule BrettProjekt.Game do
  use GenServer

  @enforce_keys [:game_id]
  defstruct [
    :game_id,
    {:id_count, 0},
    {:players, %{}}
  ]

  # ---------- CLIENT API ----------
  def create(game_id) do
    GenServer.start_link(__MODULE__, %BrettProjekt.Game{game_id: game_id})
  end

  def get_id(game) do
    GenServer.call(game, :get_id)
  end

  def add_player(game, name) do
    GenServer.call(game, {:add_player, name})
  end

  # ---------- SERVER API ----------
  def handle_call(:get_id, _from, state) do
    {:reply, Map.get(state, :game_id), state}
  end

  def handle_call({:add_player, name}, _from, %{players: players, id_count: id} = state) do

    # If this is the very first player, make him a game-admin
    roles =
      case id == 0 do
        true -> [:admin]
        _ -> []
      end

    player = %BrettProjekt.Game.Player{id: id, name: name, roles: roles}
    players = Map.put players, id, player

    new_state = %BrettProjekt.Game{state | id_count: id + 1, players: players}

    # Reply with the added player and a list of all current players
    {:reply, {:ok, player, players}, new_state}
  end


end
