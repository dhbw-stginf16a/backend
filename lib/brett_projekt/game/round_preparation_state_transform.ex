defmodule BrettProjekt.Game.RoundPreparationStateTransformation do
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep

  def transform(%RoundPrep{} = state) do
    {:ok, state}
  end
end
