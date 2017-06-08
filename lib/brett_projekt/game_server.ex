defmodule BrettProjekt.GameServer do
  use GenServer
  alias BrettProjekt.Game.Player, as: Player

  def handle_call(:get_id, _from, state) do
    {:reply, Map.get(state, :game_id), state}
  end

  def handle_call(:get_players, _from, %{players: players} = state) do
    {:reply, players, state}
  end

  def handle_call({:add_player, player}, _from, %{players: players} = state) do
    player_id = Player.get_id player
    players = Map.put players, player_id, player

    new_state = %{state | players: players}

    # Reply with the added player and a list of all current players
    {:reply, {:ok, player, players}, new_state}
  end

  def handle_call(:get_join_enabled, _from, %{join_enabled: join_enabled} = state) do
    {:reply, join_enabled, state}
  end

  def handle_call(:disable_join, _from, state) do
    {:reply, :ok, %{state | join_enabled: false}}
  end

  def handle_call(:get_new_player_id, _from, state) do
    {:reply, state.id_count, %{state | id_count: state.id_count + 1}}
  end
end
