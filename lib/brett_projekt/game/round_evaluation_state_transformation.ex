defmodule BrettProjekt.Game.RoundEvaluationStateTransformation do
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep
  alias BrettProjekt.Game.EndGame, as: EndGame
  alias BrettProjekt.Game.RoundEvaluation, as: RoundEval

  @min_points 10
  @new_categories  [314, 592, 653]

  def transform(%RoundEval{} = state) do
    teams = state.teams
    team_points =
      for {_id, team} <- teams do
        team.players
        |> Enum.reduce(0, fn ({_id, player}, player_sum) ->
          player.questions
          |> hd
          |> Enum.reduce(player_sum, fn ({_id, question}, sum) ->
            sum + question.score
          end)
        end)
      end

    transform(teams, Enum.max(team_points))
  end

  def transform(teams, points) when points >= @min_points do
    {:ok, %EndGame{teams: teams}}
  end

  def transform(teams, _points) do
    category_map = for category_id <- @new_categories, into: %{} do
      {category_id, nil}
    end
    new_teams =
      teams
      |> Enum.map(fn {team_id, team} ->
        {team_id, %{
          players: team.players,
          categories: Map.merge(team.categories, category_map)
        }}
      end)
      |> Enum.into(%{})

    {:ok, %RoundPrep{
      teams: new_teams,
      categories: @new_categories
    }}
  end
end
