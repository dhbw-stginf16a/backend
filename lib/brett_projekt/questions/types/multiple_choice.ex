defmodule BrettProjekt.Question.Type.MultipleChoice do
  alias __MODULE__, as: MultipleChoiceQuestion

  @type question_parsing_error :: {:error, atom} | {:error, atom, []}

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

  @spec parse_answers([map]) :: [non_neg_integer]
  defp parse_answers(imported_answers) do
    # Answer is the index of the correct possibility
    Enum.map(imported_answers, fn %{"index" => index} -> index end)
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
      answers: parse_answers(imported["answers"]),
      possibilities: parse_possibilities(imported["possibilities"])
    }
  end

  @spec answer_valid?(%MultipleChoiceQuestion{}, map) :: boolean
  defp answer_valid?(_question, json) do
    answers = json["answers"]

    cond do
      answers == nil -> false
      not is_list(answers) -> false
      not Enum.all?(answers, &is_integer/1) -> false
      true -> true
    end
  end

  @spec answer_correct?(%MultipleChoiceQuestion{}, map) :: boolean
  defp answer_correct?(%MultipleChoiceQuestion{} = question, answer_json) do
    MapSet.new(question.answers) == MapSet.new(answer_json["answers"])
  end

  def correct_answer(%MultipleChoiceQuestion{} = question) do
    %{
      "answers" => question.answers
    }
  end
end
