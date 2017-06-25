defmodule BrettProjekt.Game.RoundStateTransformation do
  alias BrettProjekt.Game.Round, as: Round
  alias BrettProjekt.Game.RoundEvaluation, as: RoundEval

  def transform(%Round{} = state, questions) do
    %RoundEval{teams: %{}}
  end
end
