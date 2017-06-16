# credo:disable-for-next-line Credo.Check.Readability.ModuleNames
defmodule BrettProjekt.Question.Parser.V0_1 do
  @moduledoc """
  Parser for the question file-format version 0.1.
  """

  def parse(decoded_json) do
    categories = Map.get decoded_json, "categories"

    categories
    |> flatten_categories
    |> assign_question_ids
  end

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
    |> Enum.map(fn ({element, index}) -> {index, element} end)
    |> Enum.into(%{})
  end
end
