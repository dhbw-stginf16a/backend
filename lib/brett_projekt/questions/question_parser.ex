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
    id_count = -1

    Enum.map(questions, fn(question) ->
      id_count = id_count + 1
      {id_count, Map.put(question, "id", id_count)}
    end)
    |> Enum.into(%{})
  end
end
