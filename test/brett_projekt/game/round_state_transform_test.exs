defmodule BrettProjekt.Game.RoundStateTransformationTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.Round, as: Round
  alias BrettProjekt.Game.RoundStateTransformation, as: RoundTrafo
  alias BrettProjekt.Game.RoundEvaluationTest, as: RoundEvalTest
  alias BrettProjekt.Question.Type.Mock, as: MockedQuestion

  def get_answered_state() do
    %Round{
      teams: %{
        0 => %{
          players: %{
            0 => %{
              name: "Daniel",
              questions: [
                %{
                  6 => :correct_answer
                },
                %{
                  9 => %{
                    correct_answer: :correct_answer,
                    answer: :correct_answer,
                    score: 1
                  }
                }
              ]
            },
            1 => %{
              name: "Erik",
              questions: [
                %{
                  4 => :wrong_answer,
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
                  19 => :correct_answer,
                  2 => :wrong_answer,
                  6 => :invalid_answer
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
                  42 => :correct_answer,
                  28 => nil,
                  1 => :correct_answer
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

  # TODO make private
  def get_questions_map() do
    question_list = [1, 2, 4, 6, 9, 19, 28, 42]
    for question_id <- question_list, into: %{} do
      {question_id, %MockedQuestion{
        id: :whatever,
        correct_answer: :correct_answer,
        valid_wrong_answer: :wrong_answer
      }}
    end
  end

  # wrong answer results in a score of 0
  # invalid answer results in a score of 0
  # correct answer results in a score of 1
  test "evaluation of answers" do
    evaluated_round = RoundTrafo.transform(
      get_answered_state(), get_questions_map())
    assert {:ok, RoundEvalTest.get_base_state()} == evaluated_round
  end
end
