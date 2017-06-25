defmodule BrettProjekt.Game.RoundEvaluationTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.RoundEvaluation, as: RoundEval

  def get_base_state() do
    %RoundEval{
      teams: %{
        0 => %{
          players: %{
            0 => %{
              name: "Daniel",
              questions: [
                %{
                  6 => %{
                    answer: :correct_answer,
                    correct_answer: :correct_answer,
                    score: 1
                  }
                }
              ]
            },
            1 => %{
              name: "Erik",
              questions: [
                %{
                  4 => %{
                    answer: :wrong_answer,
                    correct_answer: :correct_answer,
                    score: 0
                  },
                  9 => %{
                    answer: :wrong_answer,
                    correct_answer: :correct_answer,
                    score: 0
                  }
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
                  19 => %{
                    answer: :correct_answer,
                    correct_answer: :correct_answer,
                    score: 1
                  },
                  2 => %{
                    answer: :wrong_answer,
                    correct_answer: :correct_answer,
                    score: 0
                  },
                  6 => %{
                    answer: :invalid_answer,
                    correct_answer: :correct_answer,
                    score: 0
                  }
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
                  42 => %{
                    answer: :correct_answer,
                    correct_answer: :correct_answer,
                    score: 1
                  },
                  28 => %{
                    answer: :wrong_answer,
                    correct_answer: :correct_answer,
                    score: 0
                  },
                  1 => %{
                    answer: :correct_answer,
                    correct_answer: :correct_answer,
                    score: 1
                  }
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
end
