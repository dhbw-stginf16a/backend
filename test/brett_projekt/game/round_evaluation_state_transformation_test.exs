defmodule BrettProjekt.Game.RoundEvaluationStateTransformationTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.RoundEvaluation, as: RoundEval
  alias BrettProjekt.Game.RoundEvaluationStateTransformation,
    as: RoundEvalTrafo
  alias BrettProjekt.Game.RoundEvaluationTest, as: RoundEvalTest
  alias BrettProjekt.Game.EndGame, as: EndGame
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep

  # large number to ensure that the team is going to win this
  @large_number 10000
  @new_categories  [314, 592, 653]

  test "transformation to game end" do
    base_state = RoundEvalTest.get_base_state()

    # set score of one question to a large number to force end game
    player_questions = base_state.teams[0].players[0].questions
    new_question = put_in(hd(player_questions)[6].score, @large_number)
    new_qs = List.replace_at(player_questions, 0, new_question)
    base_state = put_in(base_state.teams[0].players[0].questions, new_qs)
    goal_state = %{base_state | __struct__: EndGame}
    assert {:ok, goal_state} == RoundEvalTrafo.transform(base_state)
  end

  test "transformation to round prep" do
    base_state = RoundEvalTest.get_base_state()

    category_map = for category_id <- @new_categories, into: %{} do
      {category_id, nil}
    end
    new_teams =
      base_state.teams
      |> Enum.map(fn {team_id, team} ->
        {team_id, %{
          players: team.players,
          categories: Map.merge(team.categories, category_map)
        }}
      end)
      |> Enum.into(%{})

    goal_state = %RoundPrep{
      teams: new_teams,
      categories: @new_categories
    }
    assert {:ok, goal_state} == RoundEvalTrafo.transform(base_state)
  end

end
