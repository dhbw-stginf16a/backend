defmodule BrettProjekt.Question.Type.MultipleChoice do
  alias __MODULE__, as: MultipleChoiceQuestion
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

  defp parse_answer(imported_answers) do
    # Answer is the index of the correct possibility
    Map.get(hd(imported_answers), "index")
  end

  defp parse_possibilities(imported_possibilities) do
    Enum.reduce(imported_possibilities, %{}, fn (possibility, acc) ->
      Map.put acc, possibility["index"], possibility["text"]
    end)
  end

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

  {:ok, true}
  {:ok, false}
  {:error, :answer_invalid}

  defp answer_valid?(json) do
    answer = json["answer"]

    answer != nil and is_integer(answer)
  end

  defp answer_correct?(%MultipleChoiceQuestion{} = question, answer_json) do
    question.answer == answer_json["answer"]
  end

  def validate_answer(%MultipleChoiceQuestion{} = question, answer_json) do
    if answer_valid? answer_json do
      answer_correct?(question, answer_json)
    else
      {:error, :answer_invalid}
    end
  end
end
