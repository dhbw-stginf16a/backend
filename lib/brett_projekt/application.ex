defmodule BrettProjekt.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    questions_file_path = Path.join(File.cwd!, "example_questions.json")
    IO.puts ~s(Loading questions from file "#{questions_file_path}")

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(BrettProjekt.Web.Endpoint, []),
      supervisor(BrettProjekt.GameManager, [:main_game_manager]),
      supervisor(BrettProjekt.Question.ServerManager,
                 [:main_question_manager, questions_file_path])
      # Start your own worker by calling:
      # BrettProjekt.Worker.start_link(arg1, arg2, arg3)
      # worker(BrettProjekt.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BrettProjekt.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
