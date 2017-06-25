defmodule BrettProjekt.Web.MainChannel do
  use Phoenix.Channel
  alias BrettProjekt.GameManager, as: GameManager
  alias BrettProjekt.Game, as: Game

  #@type game_id :: Game.game_id

  def join("main", _payload, socket) do
    {:ok, socket}
  end

  @type socket :: Elixir.Phoenix.Socket.t
  @type reply(msg) :: {:reply, msg, socket}

  #@spec handle_in(String.t, %{}, socket) :: reply({:ok, %{atom => game_id}})
  def handle_in("create_game", _payload, socket) do
    {:ok, _game, game_id} = GameManager.add_new_game :main_game_manager
    {:reply, {:ok, %{game_id: game_id}}, socket}
  end
end
