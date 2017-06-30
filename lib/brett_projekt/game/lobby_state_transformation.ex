defmodule BrettProjekt.Game.LobbyStateTransformation do
  alias BrettProjekt.Game.Lobby, as: Lobby
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep

  defp everyone_ready?(state) do
    Enum.reduce(state.players, true,
                fn ({_player_id, %{name: _, ready: ready}}, acc) ->
      acc and ready
    end)
  end

  defp count_players(state) do
    Enum.count state.players
  end

  # isses jetz oder net?
  @spec game_startable?(Lobby.t) ::
    {false,
      :not_everyone_ready |
      :no_players |
      :you_are_alone
    } |
    {true, nil}
  def game_startable?(state) do
    cond do
      not everyone_ready?(state) -> {false, :not_everyone_ready}
      count_players(state) == 0  -> {false, :no_players}
      count_players(state) == 1  -> {false, :you_are_alone}
      true -> {true, nil}
    end
  end

  # TODO use category provider
  def transform(%Lobby{} = state) do
    {startable, error} = game_startable?(state)
    if startable do
      {:ok, force_transform(state)}
    else
      {:error, error}
    end
  end

  @doc """
  Transform without error checking.
  """
  defp force_transform(state) do
    categories = %{
      5 => "BWL",
      1 => "PM",
      2 => "Berliner Flughafen"
    }
    category_list = [5, 1, 2]

    category_map = for category_id <- Map.keys(categories), into: %{} do
      {category_id, nil}
    end

    teams =
      state.teams
      |> Enum.filter(fn {_, player_ids} -> not Enum.empty? player_ids end)
      |> Enum.map(fn {team_id, player_ids} ->
        {team_id, %{
          players: get_players_by_id(state, player_ids),
          categories: category_map,
          points: 0
        }}
      end)
      |> Enum.into(%{})

    %RoundPrep{
      categories: category_list,  # include categories
      teams: teams
    }
  end

  defp get_players_by_id(state, player_ids) do
    state.players
    |> Enum.filter_map(fn {player_id, _} ->
      Enum.member?(player_ids, player_id)
    end,
    fn {player_id, player} ->
      {player_id, player.name}
    end)
    |> Enum.into(%{})
  end
end
