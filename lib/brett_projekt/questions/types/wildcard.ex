defmodule BrettProjekt.Question.Type.Wildcard do
  alias BrettProjekt.Question.Type.Wildcard, as: WildcardQuestion

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

  defp parse_answer(imported_answers) do
    # Answer is the text-attribute of the first element
    Map.get(hd(imported_answers), "text")
  end

  def parse(imported) do
    %WildcardQuestion{
      id: imported["id"],
      question: imported["question"],
      category: imported["category"],
      difficulty: imported["difficulty"],
      answer: parse_answer(imported["answers"])
    }
  end

  # TODO: apply(magic, [answer_evaluation])
  def validate_answer(%WildcardQuestion{} = question, json_answer) do
    {:ok, false}
  end
end
