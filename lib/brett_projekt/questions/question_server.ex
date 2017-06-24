defmodule BrettProjekt.Question.Server do
  alias __MODULE__, as: QuestionServer

  @enforce_keys []
  defstruct [
    {:questions, %{}},
    {:categories, []}
  ]

  @doc """
  Starts the question-server without a name assigned.

  The initial set of questions will be empty.
  Add some by invoking `load_questions_from_file/2` or
  `load_questions_from_json/2`.
  """
  def start_link do
    start_link(nil)
  end

  @doc """
  Starts the question-server with a name assigned.

  The initial set of questions will be empty.
  Add some by invoking `load_questions_from_file/2` or
  `load_questions_from_json/2`.
  """
  def start_link(name) do
    Agent.start_link(fn () -> %QuestionServer{} end, name: name)
  end

  @doc """
  Load the questions from a JSON-file and replace the registered ones.

  This function reads the file and calls `load_questions_from_json/2` afterwards.
  It may return the following error-codes additionally:
    - `{:error, :file_not_found}`
    - `{:error, :file_read_error}`
  """
  def load_questions_from_file(question_server, filename) do
    case File.read filename do
      {:ok, json} -> load_questions_from_json question_server, json
      {:error, :enoent} -> {:error, :file_not_found}
      {:error, _} -> {:error, :file_read_error}
    end
  end

  @doc """
  Loads questions from a JSON-string and replaces the current set.

  ## Returns
    - `:ok`
    - `{:error, :json_decoding_error}`
    - `{:error, :file_version_not_supported}`: No parser for the file-format version available
    - `{:error, :file_invalid}`: Error while parsing the questions file
  """
  def load_questions_from_json(question_server, json) do
    case Poison.decode json do
      {:ok, decoded} ->
        case Map.get decoded, "version" do
          "1.0" ->
            parsed = BrettProjekt.Question.Parser.V1_0.parse(decoded)
            if is_map(parsed) do
              set_questions(question_server, parsed)
            else
              parsed  # Is error message
            end
          nil ->
            {:error, :file_invalid}
          _ ->
            {:error, :file_version_not_supported}
        end
      error -> {:error, :json_decoding_error, error}
    end
  end

  defp set_questions(question_server, questions) do
    Agent.update(question_server, fn state ->
      categories = get_categories_from_questions questions
      %QuestionServer{state | questions: questions, categories: categories}
    end)
  end

  @doc """
  Get all questions as a list.
  """
  @spec get_questions(pid) :: list
  def get_questions(question_server) do
    Agent.get(question_server, fn state -> Map.values state.questions end)
  end

  @doc """
  Get a question by its id.
  """
  @spec get_question(pid, integer) :: map
  def get_question(question_server, id) do
    Agent.get(question_server, fn state -> Map.get(state.questions, id) end)
  end

  @doc """
  Returns a list of all categories
  """
  @spec get_categories(pid) :: list
  def get_categories(question_server) do
    Agent.get(question_server, fn state -> state.categories end)
  end

  @doc """
  Generates a list of categories from a map of questions

  This function, depending on the list of questions, may have a big overhead.
  It is better to only call this function when importing the questions and
  buffer its output.
  """
  defp get_categories_from_questions(questions) do
    questions
    |> Enum.reduce(MapSet.new, fn({_, question}, acc) ->
      MapSet.put(acc, question.category) end)
    |> Enum.to_list
  end
end
