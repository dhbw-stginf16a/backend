defmodule BrettProjekt.Game.RoundTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.Round, as: Round

  def base_state do
    %Round{
      teams: %{
        0 => %{
          players: %{
            0 => %{
              name: "Daniel",
              questions: [
                %{
                  6 => nil
                }
              ]
            },
            1 => %{
              name: "Erik",
              questions: [
                %{
                  4 => nil,
                  9 => nil
                }
              ]
            }
          },
          categories: %{
            5 => 1,
            1 => 1,
            2 => 0
          }
        },
        1 => %{
          players: %{
            3 => %{
              name: "Vanessa",
              questions: [
                %{
                  19 => nil,
                  2 => nil,
                  6 => nil
                }
              ]
            }
          },
          categories: %{
            5 => 3,
            1 => 3,
            2 => 3
          }
        },
        2 => %{
          players: %{
            2 => %{
              name: "Dorian",
              questions: [
                %{
                  42 => nil,
                  28 => nil,
                  1 => nil
                }
              ]
            }
          },
          categories: %{
            5 => 2,
            1 => 2,
            2 => 2
          }
        }
      }
    }
  end

  @nonexistent_player_id 9001
  @unavailable_question_id 74
  @player_id 3
  @question_id_0 19
  @question_id_1 2
  @question_id_2 6

  test "answer by nonexistent user" do
    game_state = base_state()

    assert {:error, :player_nonexistent} ==
      Round.answer_questions(game_state, @nonexistent_player_id, %{})
  end

  test "answer for unavailable question" do
    game_state = base_state()

    assert {:error, :question_unavailable} ==
      Round.answer_questions(game_state, @player_id,
                             %{@unavailable_question_id => :some_answer})
  end

  test "empty answers clear all previously given ones" do
    game_state = base_state()

    {:ok, new_state} = Round.answer_questions(game_state, @player_id,
                                              %{@question_id_0 => :fancyanswer,
                                                @question_id_1 => :boringanswer})
    assert game_state != new_state

    {:ok, new_state} = Round.answer_questions(new_state, @player_id, %{})
    assert game_state == new_state
  end

  def get_player_answers(state, player_id) do
    player =
      state.teams
      |> Enum.find_value(fn ({_, team}) -> team.players[player_id] end)

    hd(player.questions)
  end

  test "partial answers replace all previously given ones" do
    game_state = base_state()

    {:ok, new_state} = Round.answer_questions(game_state, @player_id,
                                              %{@question_id_0 => :fancyanswer,
                                                @question_id_1 => :boringanswer})
    assert %{
      @question_id_0 => :fancyanswer,
      @question_id_1 => :boringanswer,
      @question_id_2 => nil
    } == get_player_answers(new_state, @player_id)

    {:ok, new_state} = Round.answer_questions(new_state, @player_id,
                                              %{@question_id_0 => :newanswer})
    assert %{
      @question_id_0 => :newanswer,
      @question_id_1 => nil,
      @question_id_2 => nil
    } == get_player_answers(new_state, @player_id)
  end

  test "answer all questions" do
    game_state = base_state()

    {:ok, new_state} = Round.answer_questions(game_state, @player_id, %{
      @question_id_0 => :fancyanswer,
      @question_id_1 => :boringanswer,
      @question_id_2 => :normalanswer
    })

    assert %{
      @question_id_0 => :fancyanswer,
      @question_id_1 => :boringanswer,
      @question_id_2 => :normalanswer
    } == get_player_answers(new_state, @player_id)
  end
end
