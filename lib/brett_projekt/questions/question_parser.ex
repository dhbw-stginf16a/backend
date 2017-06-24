# credo:disable-for-next-line Credo.Check.Readability.ModuleNames
defmodule BrettProjekt.Question.Parser.V1_0 do
  alias BrettProjekt.Question.Type, as: QuestionType
  alias QuestionType.List, as: ListQuestion
  alias QuestionType.MultipleChoice, as: MultipleChoiceQuestion
  alias QuestionType.Wildcard, as: WildcardQuestion

  @moduledoc """
  Parser for the question file-format version 1.0.
  """

  def parse(decoded_json) do
    decoded_json
    |> Map.get("categories")
    |> flatten_categories
    |> assign_question_ids
    |> to_question_structs
  end

  # TODO: Category already in question (file format change)
  defp flatten_categories(categories) do
    Enum.flat_map(Map.to_list(categories), fn({category, questions}) ->
      category_questions = Enum.map(questions, fn(question) ->
        Map.put question, "category", category
      end)
    end)
  end

  defp assign_question_ids(questions) do
    questions
    |> Enum.with_index
    |> Enum.into(%{}, fn {question, id} ->
      {id, Map.put(question, "id", id)}
    end)
  end

  def to_question_structs(questions) do
    question_structs =
      for {id, question} <- questions, into: %{} do
        {id, to_question_struct(question)}
      end

    errored_transforms =
      question_structs
      |> Enum.filter(fn {_id, struct} ->
        not is_map(struct) or not Map.has_key?(struct, :__struct__)
      end)

    if length(errored_transforms) < 1 do
      question_structs
    else
      hd(errored_transforms)
    end
  end

  def to_question_struct(question) do
    case question["type"] do
      "wildcard" -> WildcardQuestion.parse(question)
      "multipleChoice" -> MultipleChoiceQuestion.parse(question)
      "list" -> ListQuestion.parse(question)
      nil -> {:error, :question_has_no_type}
      _ -> {:error, :question_type_not_supported}
    end
  end
end
