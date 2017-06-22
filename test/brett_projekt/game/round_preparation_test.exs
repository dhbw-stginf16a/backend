defmodule BrettProjekt.Game.RoundPreparationTest do
  use ExUnit.Case, async: false
  import BrettProjekt.MonadUtil
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep

  def base_state() do
    %RoundPrep{
      categories: [5, 1, 2],
      teams: %{
        0 => %{
          players: %{
            0 => "Daniel",
            1 => "Erik"
          },
          categories: %{
            5 => nil,
            1 => nil,
            2 => nil
          }
        },
        1 => %{
          players: %{
            3 => "Vanessa"
          },
          categories: %{
            5 => nil,
            1 => nil,
            2 => nil
          }
        },
        2 => %{
          players: %{
            2 => "Dorian"
          },
          categories: %{
            5 => nil,
            1 => nil,
            2 => nil
          }
        }
      }
    }
  end

  def get_player_categories(game_state, player_id) do
    Enum.reduce(game_state.teams, [], fn ({_team_id, team}, acc) ->
      Enum.filter_map(team.categories,
                      fn {_, cat_player_id} -> player_id == cat_player_id end,
                      fn {category_id, _} -> category_id end)
      ++ acc
    end)
  end

  @player_id 0
  @other_player_id 1
  @nonexistent_player_id 9

  test "set categories" do
    game_state = base_state()
    # Valid choice assigns category and replaces old
    {:ok, new_state} = RoundPrep.set_player_categories(game_state,
                                                       @player_id, [0, 2])
    assert [0, 2] == get_player_categories(new_state, @player_id)
    {:ok, new_state} = RoundPrep.set_player_categories(new_state,
                                                       @player_id, [1])
    assert [1] == get_player_categories(new_state, @player_id)
  end

  test "set categories of nonexistent player" do
    game_state = base_state()
    # Cannot set categories for nonexistent player
    assert {:error, :player_nonexistent} ==
      RoundPrep.set_player_categories(game_state, @nonexistent_player_id, [0])
  end

  test "set unavailable category" do
    game_state = base_state()
    # Unavailable categories can not be chosen (even if valid are included)
    assert {:error, :category_unavailable} ==
      RoundPrep.set_player_categories(game_state, @player_id, [0, 9])
  end

  test "set taken categories" do
    game_state = base_state()
    # Cannot set categories taken by other players
    {:ok, new_state} = RoundPrep.set_player_categories(game_state,
                                                       @player_id, [0])
    assert {:error, :category_taken} ==
      RoundPrep.set_player_categories(new_state, @other_player_id, [0, 1])
  end

  test "set same categories" do
    game_state = base_state()
    # Choosing same categories a second time does nothing
    {:ok, new_state} = RoundPrep.set_player_categories(game_state,
                                                       @player_id, [0, 1])
    assert game_state != new_state
    assert {:ok, new_state} ==
      RoundPrep.set_player_categories(new_state,@player_id, [0, 1])
  end

  test "initial player categories" do
    game_state = base_state()
    # Player has no categories at the beginning
    assert [] == get_player_categories(game_state, @player_id)
  end

  test "clear categories" do
    game_state = base_state()
    # Clear all categories of a player
    {:ok, new_state} = RoundPrep.set_player_categories(game_state, @player_id, [1, 2])
    assert game_state != new_state
    {:ok, new_state} = RoundPrep.set_player_categories(new_state, @player_id, [])
    assert game_state == new_state
  end
end
