defmodule BrettProjekt.Game.RoundPreparationStateTransformationTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.RoundPreparationStateTransformation, as: StateTrafo
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep
  alias BrettProjekt.Game.RoundPreparationTest, as: RoundPrepTest
  alias BrettProjekt.Game.Round, as: Round
  alias BrettProjekt.Game.RoundTest, as: RoundTest

  def assign_category(game_state, team_id, category_id, player_id) do
    put_in(game_state.teams[team_id].categories[category_id], player_id)
  end

  # TODO mock question provider
  test "transform round prep to round" do
    # assign categories
    values = [
      {0, 5, 1},
      {0, 1, 1},
      {0, 2, 9},
      {1, 5, 3},
      {1, 1, 3},
      {1, 2, 3},
      {2, 5, 2},
      {2, 1, 2},
      {2, 2, 2}
    ]
    round_preparation_state =
      Enum.reduce(values, RoundPrepTest.base_state,
                  fn ({team_id, category_id, player_id}, state) ->
                    assign_category(state, team_id, category_id, player_id)
                  end)

    assert {:ok, RoundTest.base_state} == StateTrafo.transform round_preparation_state
  end

  test "cannot start game while not all categories assigned" do
    round_preparation_state = RoundPrepTest.base_state
    round_preparation_state = put_in RoundPrepTest.base_state.teams[0].categories[5], 1
    assert {:error, :not_all_categories_assigned} == StateTrafo.transform round_preparation_state
  end
end
