defmodule BrettProjekt.Game.LobbyStateTransformation do
  alias BrettProjekt.Game.Lobby, as: Lobby
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep

  def get_team_players(state, team_id) do
    for player_id <- state.teams[team_id], into: %{} do
      {player_id, state.players[player_id].name}
    end
  end

  # TODO use category provider
  def transform(%Lobby{} = state) do
    categories = [5, 1, 2]

    category_map = for category_id <- categories, into: %{} do
      {category_id, nil}
    end

    teams =
      state.teams
      |> Enum.filter(fn {_, player_ids} -> not Enum.empty? player_ids end)
      |> Enum.map(fn {team_id, player_ids} -> {team_id, %{
            players: get_team_players(state, team_id),
            categories: category_map
      }}end)
      |> Enum.into(%{})

    {:ok, %RoundPrep{
      categories: categories,
      teams: teams
    }}
  end
end
