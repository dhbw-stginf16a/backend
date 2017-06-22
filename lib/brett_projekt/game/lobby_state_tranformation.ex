defmodule BrettProjekt.Game.LobbyStateTransformation do
  alias BrettProjekt.Game.Lobby, as: Lobby

  def transform(%Lobby{} = state) do
    {:ok, state}
  end
end
