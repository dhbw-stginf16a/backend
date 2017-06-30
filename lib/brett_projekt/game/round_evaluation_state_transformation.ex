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

    transform(teams, team_points, Enum.max(team_points))
  end

  def transform(teams, team_points, max_points) when max_points >= @min_points do
    {:ok, %EndGame{teams: teams}}
  end

  def transform(teams, team_points, _points) do
    category_map = for category_id <- @new_categories, into: %{} do
      {category_id, nil}
    end
    new_teams =
      [teams, team_points]
      |> Enum.zip
      |> Enum.map(fn {{team_id, team}, points} ->
        {team_id, %{
          players: team.players,
          categories: Map.merge(team.categories, category_map),
          points: points
        }}
      end)
      |> Enum.into(%{})

    {:ok, %RoundPrep{
      teams: new_teams,
      categories: @new_categories
    }}
  end
end
