defmodule BrettProjekt.Game.LobbyStateTransformationTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.LobbyStateTransformation, as: StateTrafo
  alias BrettProjekt.Game.LobbyTest, as: LobbyTest
  alias BrettProjekt.Game.Lobby, as: Lobby
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep
  alias BrettProjekt.Game.RoundPreparationTest, as: RoundPrepTest

  # TODO integration test

  def populated_lobby() do
    %Lobby{
      teams: %{
        0 => [0, 1],
        1 => [3],
        2 => [2],
        3 => []
      },
      players: %{
        0 => %{
          name: "Daniel",
          ready: true
        },
        1 => %{
          name: "Erik",
          ready: true
        },
        2 => %{
          name: "Dorian",
          ready: true
        },
        3 => %{
          name: "Vanessa",
          ready: true
        }
      }
    }
  end

  # TODO Mock question provider
  test "transform lobby into round prep" do
    lobby_state = populated_lobby

    round_prep_state = RoundPrepTest.base_state

    # Remove unpopulated teams
    # Add categories
    assert {:ok, round_prep_state} == StateTrafo.transform lobby_state
  end

  test "everyonoe needs to be ready to start a game" do
    lobby_state = populated_lobby
    lobby_state = put_in(lobby_state.players[1].ready, false)
    assert {:error, :some_player_not_ready} == StateTrafo.transform lobby_state
  end

  test "cannot start game without players" do
    lobby_state = populated_lobby
    lobby_state = put_in(lobby_state.players, %{})
    assert {:error, :no_players} == StateTrafo.transform lobby_state
  end

  test "cannot start game with single player" do
    lobby_state = populated_lobby
    lobby_state = put_in(lobby_state.players,
                         %{0 => %{name: "Daniel", ready: true}})
    assert {:error, :you_are_alone} == StateTrafo.transform lobby_state
  end
end
