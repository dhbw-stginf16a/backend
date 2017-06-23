defmodule BrettProjekt.Game.RoundPreparationStateTransformationTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.RoundPreparationStateTransformation, as: StateTrafo
  alias BrettProjekt.Game.RoundPreparationTest, as: RoundPrepTest
  alias BrettProjekt.Game.RoundTest, as: RoundTest

  defp assign_category(game_state, team_id, category_id, player_id) do
    put_in(game_state.teams[team_id].categories[category_id], player_id)
  end

  def get_prepared_round() do
    # assign categories
    values = [
      {0, 5, 1},
      {0, 1, 1},
      {0, 2, 0},
      {1, 5, 3},
      {1, 1, 3},
      {1, 2, 3},
      {2, 5, 2},
      {2, 1, 2},
      {2, 2, 2}
    ]
    Enum.reduce(values, RoundPrepTest.get_base_state(),
                fn ({team_id, category_id, player_id}, state) ->
                  assign_category(state, team_id, category_id, player_id)
                end)
  end

  # TODO mock question provider
  defp get_questions() do
    questions = %{
      0 => %{
        1 => %{
          4 => :question
        },
        2 => %{
          6 => :question
        },
        5 => %{
          9 => :question
        },
      },
      1 => %{
        1 => %{
          2 => :question
        },
        2 => %{
          6 => :question
        },
        5 => %{
          19 => :question
        }
      },
      2 => %{
        1 => %{
          1 => :question
        },
        2 => %{
          42 => :question
        },
        5 => %{
          28 => :question
        }
      }
    }
  end

  test "transform round prep to round" do
    assert {:ok, RoundTest.get_base_state()} ==
      StateTrafo.transform(get_prepared_round(), get_questions())
  end

  test "cannot start game while not all categories assigned" do
    round_preparation_state =
      get_prepared_round()
      |> assign_category(0, 5, nil)
    assert {:error, :not_all_categories_assigned} ==
      StateTrafo.transform(round_preparation_state, get_questions())
  end
end
