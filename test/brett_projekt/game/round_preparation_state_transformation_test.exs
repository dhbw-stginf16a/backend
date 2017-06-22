defmodule BrettProjekt.Game.RoundPreparationStateTransformationTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.RoundPreparationStateTransformation, as: StateTrafo
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep
  alias BrettProjekt.Game.RoundPreparationTest, as: RoundPrepTest
  alias BrettProjekt.Game.Round, as: Round
  alias BrettProjekt.Game.RoundTest, as: RoundTest

  # TODO mock question provider
  # TODO pipes!
  test "transform round prep to round" do
    round_preparation_state = RoundPrepTest.base_state
    # assign categories
    # team 0
    round_preparation_state = put_in RoundPrepTest.base_state.teams[0].categories[5], 1
    round_preparation_state = put_in RoundPrepTest.base_state.teams[0].categories[1], 1
    round_preparation_state = put_in RoundPrepTest.base_state.teams[0].categories[2], 0
    # team 1
    round_preparation_state = put_in RoundPrepTest.base_state.teams[1].categories[5], 3
    round_preparation_state = put_in RoundPrepTest.base_state.teams[1].categories[1], 3
    round_preparation_state = put_in RoundPrepTest.base_state.teams[1].categories[2], 3
    # team 2
    round_preparation_state = put_in RoundPrepTest.base_state.teams[2].categories[5], 2
    round_preparation_state = put_in RoundPrepTest.base_state.teams[2].categories[1], 2
    round_preparation_state = put_in RoundPrepTest.base_state.teams[2].categories[2], 2

    round_state = RoundTest.base_state
    assert round_state == StateTrafo.transform round_preparation_state
  end

  test "cannot start game while not all categories assigned" do
    round_preparation_state = RoundPrepTest.base_state
    round_preparation_state = put_in RoundPrepTest.base_state.teams[0].categories[5], 1
    assert {:error, :not_all_categories_assigned} == StateTrafo.transform round_preparation_state
  end
end
