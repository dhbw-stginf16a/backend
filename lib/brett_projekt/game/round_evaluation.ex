defmodule BrettProjekt.Game.RoundEvaluation do
  defstruct [
    {:teams, %{}}
  ]

  @doc """
  Arguments:
  - questions_map is an alternative question server used for testing
  """
  def evaluate_round(game_state, questions_map) do
    # TODO do this for all questions
    #case Question.validate_answer(questions_map, question_id, answer) do
    #  {:ok, true} ->
    #    score = 1
    #  {:ok, false} ->
    #    score = 0
    #  {:error, :answer_invalid} ->
    #    score = 0
    #  # {:error, :question_not_found} ->  should never occur
    #end
    game_state
  end
end
