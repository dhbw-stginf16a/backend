defmodule BrettProjekt.Question.Type.MultipleChoice do
  alias __MODULE__, as: MultipleChoiceQuestion

  @type question_parsing_error :: {:error, atom} | {:error, atom, []}

  @enforce_keys [
    :id,
    :question,
    :category,
    :difficulty,
    :answer,
    :possibilities
  ]
  defstruct [
    :id,
    :question,
    :category,
    :difficulty,
    :answer,
    :possibilities
  ]

  @spec parse_answer([map]) :: non_neg_integer
  defp parse_answer(imported_answers) do
    # Answer is the index of the correct possibility
    Map.get(hd(imported_answers), "index")
  end

  @spec parse_possibilities(map) :: %{non_neg_integer => String.t}
  defp parse_possibilities(imported_possibilities) do
    Enum.reduce(imported_possibilities, %{}, fn (possibility, acc) ->
      Map.put acc, possibility["index"], possibility["text"]
    end)
  end

  @spec parse(map) :: %MultipleChoiceQuestion{}
  def parse(imported) do
    %MultipleChoiceQuestion{
      id: imported["id"],
      question: imported["question"],
      category: imported["category"],
      difficulty: imported["difficulty"],
      answer: parse_answer(imported["answers"]),
      possibilities: parse_possibilities(imported["possibilities"])
    }
  end

  @spec answer_valid?(%MultipleChoiceQuestion{}, map) :: boolean
  defp answer_valid?(_question, json) do
    answer = json["answer"]

    answer != nil and is_integer(answer)
  end

  @spec answer_correct?(%MultipleChoiceQuestion{}, map) :: boolean
  defp answer_correct?(%MultipleChoiceQuestion{} = question, answer_json) do
    question.answer == answer_json["answer"]
  end
end
