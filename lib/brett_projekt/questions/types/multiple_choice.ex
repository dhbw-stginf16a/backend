defmodule BrettProjekt.Question.Type.MultipleChoice do
  alias __MODULE__, as: MultipleChoiceQuestion
  @enforce_keys [
    :id,
    :question,
    :category,
    :difficulty,
    :answers,
    :possibilities
  ]
  defstruct [
    :id,
    :question,
    :category,
    :difficulty,
    :answers,
    :possibilities
  ]

  defp parse_answers(imported_answers) do
    # Answer is the index of the correct possibility
    Enum.map(imported_answers, fn %{"index" => index} -> index end)
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
      answers: parse_answers(imported["answers"]),
      possibilities: parse_possibilities(imported["possibilities"])
    }
  end

  defp answer_valid?(_question, json) do
    answers = json["answers"]

    cond do
      answers == nil -> false
      not is_list(answers) -> false
      not Enum.all?(answers, &is_integer/1) -> false
      true -> true
    end
  end

  defp answer_correct?(%MultipleChoiceQuestion{} = question, answer_json) do
    MapSet.new(question.answers) == MapSet.new(answer_json["answers"])
  end

  def correct_answer(%MultipleChoiceQuestion{} = question) do
    %{
      "answers" => question.answers
    }
  end
end
