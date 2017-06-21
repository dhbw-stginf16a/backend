defmodule BrettProjekt.Game.Lobby do

  defstruct [
    {:teams, %{}},
    {:players, %{}}
  ]

  def create_game(team_count) do
    %__MODULE__{}
  end

  def add_player(game_state, player_name) do
    game_state
  end

  def switch_team(game_state, player_id, team_id) do
    game_state
  end

  def set_ready(game_state, player_id, ready) do
    game_state
  end
end
