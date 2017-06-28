defmodule BrettProjekt.Question.Type.List do
  alias BrettProjekt.Question.Type.List, as: ListQuestion

  @type question_parsing_error :: {:error, atom} | {:error, atom, []}

  @enforce_keys [
    :id,
    :question,
    :category,
    :difficulty,
    :answers,
    :required_answers
  ]
  defstruct [
    :id,
    :question,
    :category,
    :difficulty,
    :answers,
    :required_answers
  ]

  @spec parse_answers([map]) :: [String.t]
  defp parse_answers(imported_answers) do
    Enum.map(imported_answers, fn answer ->
      normalize_answer(answer["text"])
    end)
  end

  @spec parse(map) :: %ListQuestion{} | question_parsing_error
  def parse(imported) do
    %BrettProjekt.Question.Type.List{
      id: imported["id"],
      question: imported["question"],
      category: imported["category"],
      difficulty: imported["difficulty"],
      answers: parse_answers(imported["answers"]),
      required_answers: imported["requiredAnswers"]
    }
  end

  @spec answer_valid?(%ListQuestion{}, map) :: boolean
  def answer_valid?(_question, json) do
    case json["answers"] do
      answers when is_list answers ->
        invalid_elements =
          Enum.filter(answers, &(not String.valid? &1))

        length(invalid_elements) > 0
      _ -> false
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

  @spec answer_correct?(%ListQuestion{}, map) :: boolean
  defp answer_correct?(%ListQuestion{} = question, answer_json) do
    {correct_answers, _used_solutions} =
      answer_json["answers"]
      |> Enum.reduce({0, []}, fn (answer, {correct_count, used_solutions}) ->
        # We store the used solutions in the accumulator-tuple as we don't
        # want the user to be able to enter the same answer twice

        # Returns nil if the answer is wrong, index of the solution if right
        answer_pos = Enum.find(question.answers, fn solution ->
          # Check the answer with a simple string comparison
          solution == normalize_answer(answer)
        end)

        if answer_pos != nil and not Enum.member?(used_solutions, answer_pos) do
          {correct_count + 1, [answer_pos | used_solutions]}
        else
          {correct_count, used_solutions}
        end
      end)

    correct_answers >= question.required_answers
  end

  def correct_answer(%ListQuestion{} = question) do
    %{
      "answers" => question.answers
    }
  end
end
