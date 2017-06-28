defmodule BrettProjekt.Question.Type.FillIn do
  alias BrettProjekt.Question.Type.FillIn, as: FillInQuestion

  @type question_parsing_error :: {:error, atom} | {:error, atom, []}

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

  @spec parse_question(String.t) :: [String.t]
  defp parse_question(imported_question) do
    placeholder = "..."
    String.split(imported_question, placeholder)
  end

  @spec parse_answers([map]) :: %{non_neg_integer => String.t}
  defp parse_answers(imported_answers) do
    for answer <- imported_answers, into: %{} do
      {answer["index"], normalize_answer(answer["text"])}
    end
  end

  @spec question_valid?(map) :: boolean
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

  @spec parse(map) :: %FillInQuestion{} | question_parsing_error
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

  @spec remove_non_alphanumeric_chars(String.t) :: String.t
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

  @spec normalize_answer(String.t) :: String.t
  defp normalize_answer(answer) do
    answer
    |> String.downcase
    |> String.replace("ä", "ae")
    |> String.replace("ü", "ue")
    |> String.replace("ö", "oe")
    |> String.replace("ß", "ss")
    |> remove_non_alphanumeric_chars
  end

  @spec answer_valid?(%FillInQuestion{}, map) :: boolean
  def answer_valid?(%FillInQuestion{} = question, answer_json) do
    invalid_answers =
      answer_json["answers"]
      |> Enum.with_index
      |> Enum.filter(fn {answer, pos} ->
        cond do
          not String.valid?(answer) -> true
          question.answers[pos] == nil -> true
          true -> false
        end
      end)

    length(invalid_answers) < 1
  end

  @spec answer_correct?(%FillInQuestion{}, map) :: boolean
  defp answer_correct?(%FillInQuestion{} = question, answer_json) do
    correct_answers =
      answer_json["answers"]
      |> Enum.with_index
      |> Enum.filter(fn {answer, pos} ->
        solution = question.answers[pos]

        String.equivalent?(solution, normalize_answer(answer))
      end)

    length(correct_answers) == Enum.count(question.answers)
  end
end
