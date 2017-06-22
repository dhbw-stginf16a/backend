defmodule BrettProjekt.Game.RoundPreparation do

  defstruct [
    {:categories, []},
    {:teams, %{}}
  ]

  def set_player_categories(game_state, player_id, category_ids) do
    {:ok, game_state}
  end
end
