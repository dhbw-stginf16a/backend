defmodule BrettProjekt.Game.Lobby do
  alias BrettProjekt.Game.Lobby, as: Lobby

  defstruct [
    {:teams, %{}},
    {:players, %{}}
  ]

  @type team :: [non_neg_integer]
  @type player_id :: non_neg_integer
  @type team_id :: non_neg_integer
  @type lobby_state :: %Lobby{teams: map, players: map}

  @spec least_populated_team(%Lobby{teams: map}) :: integer
  defp least_populated_team(%Lobby{} = game_state) do
    teams = game_state.teams

    {smallest_team, _} =
      Enum.reduce(teams, {-1, nil}, fn ({team_id, team}, {small_tid, small_ts}) ->
        if small_ts == nil or small_ts > length(team) do
          {team_id, length(team)}
        else
          {small_tid, small_ts}
        end
      end)

    smallest_team
  end

  @spec get_player_team_id(lobby_state, player_id) :: team_id
  defp get_player_team_id(game_state, player_id) do
    {team_id, team} =
      Enum.find(game_state.teams, fn {_, team} -> Enum.member? team, player_id end)

    team_id
  end

  @spec add_player_to_team(team, player_id) :: team
  defp add_player_to_team(team, player_id) do
    if Enum.member?(team, player_id) do
      team
    else
      [player_id | team]
    end
  end

  @spec remove_player_from_team(team, player_id) :: team
  defp remove_player_from_team(team, player_id) do
    Enum.filter(team, fn p_id -> p_id != player_id end)
  end

  @spec create_game(pos_integer) :: lobby_state
  def create_game(team_count) do
    teams =
      for team_id <- 0..(team_count - 1), into: %{} do
        {team_id, []}
      end

    %Lobby{teams: teams}
  end

  @spec add_player(lobby_state, String.t) :: {:ok, lobby_state}
  def add_player(game_state, player_name) do
    player = %{name: player_name, ready: false}
    player_id = length Map.values game_state.players
    team_id = least_populated_team game_state

    players = Map.put game_state.players, player_id, player
    teams = %{
      game_state.teams |
      team_id => add_player_to_team(game_state.teams[team_id], player_id)
    }

    {:ok, %{game_state | players: players, teams: teams}}
  end

  @spec switch_team(lobby_state, player_id, team_id) :: {atom, any}
  def switch_team(game_state, player_id, team_id) do
    old_team_id = get_player_team_id game_state, player_id
    old_team = remove_player_from_team(game_state.teams[old_team_id], player_id)

    case game_state.teams[team_id] do
      nil -> {:error, :team_invalid}
      new_team ->
        teams = %{
          game_state.teams |
          old_team_id => old_team,
          team_id => add_player_to_team(new_team, player_id)
        }

        {:ok, %{game_state | teams: teams}}
    end
  end

  @spec set_ready(lobby_state, player_id, boolean) :: {atom, any}
  def set_ready(game_state, player_id, ready) do
    if game_state.players[player_id] == nil do
      {:error, :invalid_player_id}
    else
      game_state = put_in(game_state.players[player_id].ready, ready)
      {:ok, game_state}
    end
  end
end
