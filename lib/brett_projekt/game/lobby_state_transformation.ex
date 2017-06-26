defmodule BrettProjekt.Game.LobbyStateTransformation do
  alias BrettProjekt.Game.Lobby, as: Lobby
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep

  def get_team_players(state, team_id) do
    for player_id <- state.teams[team_id], into: %{} do
      {player_id, state.players[player_id].name}
    end
  end

  defp everyone_ready?(state) do
    Enum.reduce(state.players, true,
                fn ({_player_id, %{name: _, ready: ready}}, acc) ->
      acc and ready
    end)
  end

  defp count_players(state) do
    Enum.count state.players
  end

  # TODO use category provider
  def transform(%Lobby{} = state) do
    cond do
      not everyone_ready?(state) -> {:error, :not_everyone_ready}
      count_players(state) == 0  -> {:error, :no_players}
      count_players(state) == 1  -> {:error, :you_are_alone}
      true                       -> {:ok, force_transform(state)}
    end
  end

  @doc """
  Transform without error checking.
  """
  defp force_transform(state) do
    categories = [5, 1, 2]

    category_map = for category_id <- categories, into: %{} do
      {category_id, nil}
    end

    teams =
      state.teams
      |> Enum.filter(fn {_, player_ids} -> not Enum.empty? player_ids end)
      |> Enum.map(fn {team_id, _player_ids} -> {team_id, %{
            players: get_team_players(state, team_id),
            categories: category_map
      }}end)
      |> Enum.into(%{})

    %RoundPrep{
      categories: categories,
      teams: teams
    }
  end
end
