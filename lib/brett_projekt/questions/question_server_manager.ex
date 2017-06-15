defmodule BrettProjekt.Question.ServerManager do
  use GenServer
  alias BrettProjekt.Question.Server, as: QuestionServer
  alias __MODULE__, as: QuestionServerManager

  @moduledoc """
  Manager for handling `BrettProjekt.Question.Server` easily.

  The BrettProjekt-Game requires a question-server to be running and loaded
  with questions to ask the players.
  This module creates a server and loads the questions into it. (`load_questions_from_file/2`)

  A listener for file-changes can be enabled, so that a new question-server is
  created with the changed set of questions.

  When starting a game, the current `BrettProjekt.Question.Server` process
  should be retrieved using `get_question_server/1` and stored in the game state.
  Therefore, if a new set of questions gets loaded, existing games will keep using
  the original question-set but new games start with an up-to-date question-set.
  """

  @doc """
  Start the ServerManager without a name

  ## Examples

      iex> {:ok, server_manager} = BrettProjekt.Question.ServerManager.start_link
      iex> is_pid server_manager
      true

  """
  def start_link do
    start_link(nil)
  end

  @doc """
  Start the ServerManager under a specific name (atom)

  ## Examples

      iex> {:ok, server_manager} = BrettProjekt.Question.ServerManager.start_link :my_server_manager
      iex> is_pid server_manager
      true

  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @doc """
  Starts the ServerManager with a name and loads an initial questions-file

  To start it without a name assinged, pass nil
  """
  def start_link(name, filename) do
    {:ok, server_manager} = start_link(name)
    case load_questions_from_file server_manager, filename do
      :ok -> {:ok, server_manager}
      err -> err
    end
  end

  @doc """
  Loads questions from a JSON-file, parses it and (on success) replaces the current question-server

  ## Arguments
    - `file`: The file to load (absolute or relative path)

  ## Returns
    - `:ok`
    - `{:error, :file_not_found}`
    - `{:error, :file_read_error}`
    - `{:error, :json_decoding_error}`
    - `{:error, :file_version_not_supported}`: No parser for the file-format version available
    - `{:error, :file_invalid}`: Error while parsing the questions file
  """
  def load_questions_from_file(server_manager, file) do
    {:ok, question_server} = BrettProjekt.Question.Server.start_link
    case QuestionServer.load_questions_from_file(question_server, file) do
      :ok ->
        # A new QuestionServer instance has been created, save it as the current
        GenServer.call(server_manager,
                       {:replace_question_server, question_server})
      error -> error
    end
  end

  @doc """
  Retrieves the current question-server

  This value needs to be cached per Game to prevent changing the question-set
  (including ids, etc.)

  ## Returns
    - `{:error, :no_question_server}`: No question-server has been started yet.
    - `{:ok, pid_of_question_server}`
  """
  def get_question_server(server_manager) do
    GenServer.call(server_manager, :get_question_server)
  end

  def handle_call({:replace_question_server, question_server}, _from, _state) do
    {:reply, :ok, question_server}
  end

  def handle_call(:get_question_server, _from, state) do
    case state do
      nil -> {:reply, {:error, :no_question_server}, state}
      _ -> {:reply, {:ok, state}, state}
    end
  end
end
