defmodule BrettProjekt.Game.RoundPreparation do

  @type t :: %__MODULE__{
    categories: [category_id],
    teams: %{
      team_id => %{
        players: %{
          player_id => String.t
        },
        categories: %{
          category_id => player_id
        }
      }
    }
  }
  defstruct [
    {:categories, []},
    {:teams, %{}}
  ]

  # move all those types in a common module
  @type team :: [non_neg_integer]
  @type player_id :: non_neg_integer
  @type team_id :: non_neg_integer
  @type category_id :: non_neg_integer

  defp any_category_taken?(game_state, category_ids, player_id) do
    {_team_id, team} =
      Enum.find(game_state.teams, fn {_team_id, team} ->
        team.players
        |> Map.keys
        |> Enum.member?(player_id)
      end)
    Enum.any?(category_ids, fn category_id ->
      # see http://www.urbandictionary.com/define.php?term=mooch
      mooch = team.categories[category_id]
      mooch != nil && mooch != player_id
    end)
  end

  defp any_category_unavailable?(game_state, category_ids) do
    unavailable = MapSet.difference(MapSet.new(category_ids),
                                    MapSet.new(game_state.categories))
    Enum.count(unavailable) > 0
  end

  defp player_nonexistent?(game_state, player_id) do
    players =
      Enum.flat_map(game_state.teams, fn {_id, team} ->
        Map.keys(team.players)
      end)

    not Enum.member?(players, player_id)
  end

  def set_player_categories(game_state, player_id, category_ids) do
    cond do
      player_nonexistent?(game_state, player_id) ->
        {:error, :player_nonexistent}
      any_category_taken?(game_state, category_ids, player_id) ->
        {:error, :category_taken}
      any_category_unavailable?(game_state, category_ids) ->
        {:error, :category_unavailable}
      true ->
        {:ok, force_set_player_categories(game_state, player_id, category_ids)}
    end
  end

  defp force_set_player_categories(game_state, player_id, category_ids) do
    teams =
      game_state.teams
      |> Enum.map(fn {team_id, %{players: players, categories: categories,
                                 points: points}} ->
        categories =
          if players |> Map.keys |> Enum.member?(player_id) do
            map_set_values(categories, category_ids, player_id)
          else
            categories
          end
        {team_id, %{
          players: players,
          categories: categories,
          points: points
        }}
      end)
      |> Enum.into(%{})
    %__MODULE__{
      categories: game_state.categories,
      teams: teams
    }
  end

  # Set multiple keys to the same value
  defp map_set_values(map, keys, value) do
    map
    |> Enum.map(fn {category_id, _answerer_id} ->
      answerer_id =
        if Enum.member?(keys, category_id) do
          value
        else
          nil
        end
      {category_id, answerer_id}
    end)
    |> Enum.into(%{})
  end

  def get_broadcast(prep_state) do
    {:ok, {prep_state, %{
      categories: %{
        7 => "Some very unimportant stuff",
        2 => "Anything at all",
        3 => "Covfefe",
      },
      teams: prep_state.teams
    }}}
  end
end
