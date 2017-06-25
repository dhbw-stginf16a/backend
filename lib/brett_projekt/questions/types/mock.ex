defmodule BrettProjekt.Question.Type.Mock do
  alias BrettProjekt.Question.Type.Mock, as: MockQuestion

  @enforce_keys [
    :id,
    :correct_answer,
    :valid_wrong_answer
  ]
  defstruct [
    :id,
    :correct_answer,
    :valid_wrong_answer
  ]

  def answer_valid?(%MockQuestion{correct_answer: corr} = question, corr), do: true
  def answer_valid?(%MockQuestion{valid_wrong_answer: wrong} = question, wrong), do: true
  def answer_valid?(%MockQuestion{} = question, _answer), do: false

  def answer_correct?(%MockQuestion{correct_answer: corr} = question, corr), do: true
  def answer_correct?(%MockQuestion{} = question, _answer), do: false
end
