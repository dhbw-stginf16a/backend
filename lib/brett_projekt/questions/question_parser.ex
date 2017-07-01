# credo:disable-for-next-line Credo.Check.Readability.ModuleNames
defmodule BrettProjekt.Question.Parser.V1_0 do
  alias BrettProjekt.Question.Type, as: QuestionType
  alias QuestionType.List, as: ListQuestion
  alias QuestionType.MultipleChoice, as: MultipleChoiceQuestion
  alias QuestionType.Wildcard, as: WildcardQuestion
  alias QuestionType.FillIn, as: FillInQuestion

  @moduledoc """
  Parser for the question file-format version 1.0.
  """

  @type question_id :: non_neg_integer
  @type category_id :: non_neg_integer
  @type question_struct :: map
  @type question_parsing_error :: {:error, error_code :: atom} |
                                  {:error, error_code :: atom, msg :: atom}
  @type json_object :: %{String.t => any}

  @doc """
  Further parse the incoming data already in elixir datastructures (by Poison)

  This will generate a map of categories (%{category_id: label}) as well as a
  map of questions (%{question_id: question})
  """
  @spec parse(json_object) ::
    {%{question_id => question_struct}, %{category_id => String.t}} |
    question_parsing_error
  def parse(decoded_json) do
    {questions, categories_map} =
      decoded_json
      |> Map.get("categories")
      |> flatten_categories

    question_structs =
      questions
      |> assign_question_ids
      |> to_question_structs

    if is_map(question_structs) do
      # Everything fine
      {question_structs, categories_map}
    else
      # question_structs is probably an error, return it
      question_structs
    end
  end

  def get_highest_list_value(list, default \\ nil)
  def get_highest_list_value([], default), do: default
  def get_highest_list_value(list, _default) do
    list
    |> Enum.sort
    |> Enum.take(-1)
    |> hd
  end

  @spec get_category_id(String.t, map) :: {non_neg_integer, map}
  def get_category_id(category_label, categories_map) do
    result =
      Enum.find(categories_map, fn {_cat_id, cat_label} ->
        cat_label == category_label
      end)

    if result == nil do
      new_id = get_highest_list_value(Map.keys(categories_map), -1) + 1

      {new_id, Map.put(categories_map, new_id, category_label)}
    else
      {id, _label} = result
      {id, categories_map}
    end
  end

  @spec flatten_categories(json_object) :: {[json_object], map}
  defp flatten_categories(categories) do
    Enum.reduce(categories, {[], %{}},
                fn({cat_label, cat_questions}, {questions, categories_map}) ->
      {cat_id, categories_map} = get_category_id(cat_label, categories_map)

      category_questions = Enum.map(cat_questions, fn(question) ->
        Map.put(question, "category", cat_id)
      end)

      {questions ++ category_questions, categories_map}
    end)
  end

  @spec assign_question_ids([json_object]) :: %{question_id => json_object}
  defp assign_question_ids(questions) do
    questions
    |> Enum.with_index
    |> Enum.into(%{}, fn {question, id} ->
      {id, Map.put(question, "id", id)}
    end)
  end

  @spec to_question_structs(%{question_id => json_object})
                           :: %{question_id => question_struct} |
                              question_parsing_error
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

  @spec to_question_struct(json_object) :: question_struct |
                                           question_parsing_error
  def to_question_struct(question) do
    case question["type"] do
      "wildcard" -> WildcardQuestion.parse(question)
      "multipleChoice" -> MultipleChoiceQuestion.parse(question)
      "list" -> ListQuestion.parse(question)
      "fillIn" -> FillInQuestion.parse(question)
      nil -> {:error, :question_has_no_type}
      type -> {:error, :question_type_not_supported, type}
    end
  end
end
