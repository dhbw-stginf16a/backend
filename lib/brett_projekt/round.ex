defmodule BrettProjekt.Game.Round do
  defstruct [
    {:teams, []}
  ]

  @doc """
  ## Arguments:
  - question_sets: set of question ids for each team
  """
  def initialize(question_sets) do
    # TODO check all question_sets same size

    teams = 
    %__MODULE__{
      teams: for question_set <- question_sets do
        for question_id <- question_set, into: %{} do
          {question_id, nil}
        end
      end
    }
  end
end
