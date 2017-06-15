defmodule BrettProjekt.Question.Server do
  use GenServer
  alias BrettProjekt.Question.Parser, as: QuestionParser
  alias __MODULE__, as: QuestionServer

  @enforce_keys []
  defstruct [
    {:questions, %{}}
  ]

  @doc """
  Starts the question-server without a name assigned.
  
  The initial set of questions will be empty.
  Add some by invoking `load_questions_from_file/2` or
  `load_questions_from_json/2`.
  """
  def start_link() do
    start_link(nil)
  end

  @doc """
  Starts the question-server with a name assigned.

  The initial set of questions will be empty.
  Add some by invoking `load_questions_from_file/2` or
  `load_questions_from_json/2`.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, %QuestionServer{}, name: name)
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
          0.1 ->
            GenServer.call(question_server, {:set_questions, BrettProjekt.Question.Parser.V0_1.parse(decoded)})
          nil ->
            {:error, :file_invalid}
          _ ->
            {:error, :file_version_not_supported}
        end
      error -> {:error, :json_decoding_error, error}
    end
  end

  @doc """
  Get all questions as a list.
  """
  @spec get_questions(pid) :: list
  def get_questions(question_server) do
    GenServer.call(question_server, :get_questions)
  end

  @doc """
  Get a question by its id.
  """
  @spec get_question(pid, integer) :: map
  def get_question(question_server, id) do
    GenServer.call(question_server, {:get_question, id})
  end

  def handle_call({:set_questions, questions}, _from, state) do
    {:reply, :ok, %{state | questions: questions}}
  end

  def handle_call(:get_questions, _from, state) do
    question_list =
      Enum.to_list(state.questions)
      |> Enum.map(fn ({id, question}) -> question end)

    {:reply, question_list, state}
  end

  def handle_call({:get_question, id}, _from, state) do
    {:reply, state.questions[id], state}
  end
end

