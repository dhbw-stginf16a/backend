defmodule BrettProjekt.Game do
  use GenServer

  @enforce_keys [:game_id]
  defstruct [
    :game_id,
    {:users, []}
  ]

  def create(game_id) do
    GenServer.start_link(__MODULE__, %BrettProjekt.Game{ game_id: game_id })
  end

  def get_id(game) do
    GenServer.call(game, :get_id)
  end


  def handle_call(:get_id, _from, state) do
    {:reply, Map.get(state, :game_id), state}
  end

end
