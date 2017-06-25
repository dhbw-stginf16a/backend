defmodule BrettProjekt.Game do
  alias __MODULE__, as: Game

  @spec create(pos_integer) :: {:ok, pid}
  def create(team_count) do
    Agent.start_link(fn () -> Game.Lobby.create_game(team_count) end)
  end
end
