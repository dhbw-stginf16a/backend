defmodule BrettProjekt.Question.Type.FillIn do
  alias BrettProjekt.Question.Type.FillIn, as: FillInQuestion

  @enforce_keys [
    :id,
    :question,
    :category,
    :difficulty,
    :answers
  ]
  defstruct [
    :id,
    :question,
    :category,
    :difficulty,
    :answers
  ]

  defp parse_question(imported_question) do
    placeholder = "..."
    String.split(imported_question, placeholder)
  end

  defp parse_answers(imported_answers) do
    for answer <- imported_answers, into: %{} do
      {answer["index"], normalize_answer(answer["text"])}
    end
  end

  defp question_valid?(imported) do
    placeholders = length(parse_question(imported["question"])) - 1
    answers = Enum.count(parse_answers(imported["answers"]))

    # Todo: Check if answers-ids are continous (0..n)

    if placeholders != answers do
      false
    else
      true
    end
  end

  def parse(imported) do
    if question_valid? imported do
      %BrettProjekt.Question.Type.FillIn{
        id: imported["id"],
        question: parse_question(imported["question"]),
        category: imported["category"],
        difficulty: imported["difficulty"],
        answers: parse_answers(imported["answers"])
      }
    else
      {:error, :question_invalid, question: imported["question"]}
    end
  end

  defp remove_non_alphanumeric_chars(string) do
    valid_chars =
      [
        Enum.map(?a..?z, fn n -> << n :: utf8 >> end),
        Enum.map(?0..?9, fn n -> << n :: utf8 >> end)
      ]
      |> List.flatten

    string
    |> to_charlist
    |> Enum.filter(fn char -> Enum.member?(valid_chars, << char :: utf8 >>) end)
    |> to_string
  end

  defp normalize_answer(answer) do
    answer
    |> String.downcase
    |> String.replace("ä", "ae")
    |> String.replace("ü", "ue")
    |> String.replace("ö", "oe")
    |> String.replace("ß", "ss")
    |> remove_non_alphanumeric_chars
  end
end
