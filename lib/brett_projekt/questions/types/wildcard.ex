defmodule BrettProjekt.Question.Type.Wildcard do
  alias BrettProjekt.Question.Type.Wildcard, as: WildcardQuestion

  @type question_parsing_error :: {:error, atom} | {:error, atom, []}

  @enforce_keys [
    :id,
    :question,
    :category,
    :difficulty,
    :answer
  ]
  defstruct [
    :id,
    :question,
    :category,
    :difficulty,
    :answer
  ]

  @spec parse_answer([map]) :: String.t
  defp parse_answer(imported_answers) do
    # Answer is the text-attribute of the first element
    Map.get(hd(imported_answers), "text")
  end

  @spec parse(map) :: %WildcardQuestion{}
  def parse(imported) do
    %WildcardQuestion{
      id: imported["id"],
      question: imported["question"],
      category: imported["category"],
      difficulty: imported["difficulty"],
      answer: parse_answer(imported["answers"])
    }
  end

  # TODO: check if unknown format is valid
  @spec answer_valid?(%WildcardQuestion{}, map) :: boolean
  def answer_valid?(%WildcardQuestion{} = question, json_answer) do
    false
  end

  # TODO: apply(magic, [answer_evaluation])
  @spec answer_correct?(%WildcardQuestion{}, map) :: boolean
  def answer_correct?(%WildcardQuestion{} = question, json_answer) do
    false
  end
end
