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

  def answer_valid?(%MockQuestion{correct_answer: corr}, corr), do: true
  def answer_valid?(%MockQuestion{valid_wrong_answer: wrong}, wrong), do: true
  def answer_valid?(%MockQuestion{}, _answer), do: false

  def answer_correct?(%MockQuestion{correct_answer: corr}, corr), do: true
  def answer_correct?(%MockQuestion{}, _answer), do: false

  def correct_answer(%MockQuestion{correct_answer: answer}), do: answer
end
