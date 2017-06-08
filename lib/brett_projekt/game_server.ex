defmodule BrettProjekt.GameServer do
  use GenServer

  def handle_call(:get_id, _from, state) do
    {:reply, Map.get(state, :game_id), state}
  end

  def handle_call(:get_players, _from, %{players: players} = state) do
    {:reply, players, state}
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

    new_state = %{state | id_count: id + 1, players: players}

    # Reply with the added player and a list of all current players
    {:reply, {:ok, player, players}, new_state}
  end

  def handle_call(:get_join_enabled, _from, %{join_enabled: join_enabled} = state) do
    {:reply, join_enabled, state}
  end

  def handle_call(:disable_join, _from, state) do
    {:reply, :ok, %{state | join_enabled: false}}
  end
end
