defmodule BrettProjekt.Web.MainChannel do
  use Phoenix.Channel
  alias BrettProjekt.GameManager, as: GameManager
  alias BrettProjekt.Game, as: Game

  def join("main", _payload, socket) do
    {:ok, socket}
  end
end
