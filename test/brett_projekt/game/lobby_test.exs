defmodule BrettProjekt.Game.LobbyTest do
  use ExUnit.Case, async: false
  alias BrettProjekt.Game.Lobby, as: Lobby

  test "create initial game-state" do
    team_count = 3
    game_state = Lobby.create_game team_count

    assert %Lobby{
      teams: %{
        0 => [],
        1 => [],
        2 => []
      },
      players: %{}
    } == game_state
  end

  @doc """
  Tests adding players to the lobby state.

  ## Conditions
    - add new player to players
      - assert new player has name and ready-state 'false'
    - assign the player exactly one team
  """
  test "add player" do
    game_state = %Lobby{
      teams: %{
        0 => [],
        1 => [],
        2 => []
      },
      players: %{}
    }

    check_player_inserted = fn (game_state, player_id, player_name) ->
      {:ok, game_state} = Lobby.add_player(game_state, player_name)

      assert %{name: player_name, ready: false} == game_state.players[player_id]

      player_teams =
        game_state.teams
        |> Enum.reduce([], fn ({team, players}, acc) ->
          if Enum.member?(players, player_id) do
            [team | acc]
          end
        end)

      # Check that the player is in exactly one team
      assert 1 == Enum.count(player_teams)

      game_state
    end

    game_state
    |> check_player_inserted.(0, "daniel")
    |> check_player_inserted.(1, "leon")
    |> check_player_inserted.(2, "thore")
    |> check_player_inserted.(3, "vanessa")
  end

  test "switch team" do
    game_state = %Lobby{
      teams: %{
        0 => [],
        1 => [0],
        2 => [1]
      },
      players: %{
        0 => %{
          name: "vanessa",
          ready: true
        },
        1 => %{
          name: "uwe",
          ready: false
        }
      }
    }

    # Switch to an empty team
    {:ok, game_state} = Lobby.switch_team(game_state, 0, 0)
    assert %Lobby{
      teams: %{
        0 => [0],
        1 => [],
        2 => [1]
      },
      players: %{
        0 => %{
          name: "vanessa",
          ready: true
        },
        1 => %{
          name: "uwe",
          ready: false
        }
      }
    } == game_state

    # Switch to the team the player is currently in does not alter the state
    {:ok, game_state} = Lobby.switch_team(game_state, 0, 0)
    assert %Lobby{
      teams: %{
        0 => [0],
        1 => [],
        2 => [1]
      },
      players: %{
        0 => %{
          name: "vanessa",
          ready: true
        },
        1 => %{
          name: "uwe",
          ready: false
        }
      }
    } == game_state

    # Switch into an already populated team
    {:ok, game_state} = Lobby.switch_team(game_state, 1, 0)
    assert %Lobby{
      teams: %{
        0 => [0, 1],
        1 => [],
        2 => []
      },
      players: %{
        0 => %{
          name: "vanessa",
          ready: true
        },
        1 => %{
          name: "uwe",
          ready: false
        }
      }
    } == game_state
  end

  # TODO think about replacing this with bind
  def unwrap({:ok, val}), do: val
  def unwrap(val), do: raise "Cannot unwrap #{inspect val}"

  test "set ready status" do
    game_state = %Lobby{
      teams: %{
        0 => [],
        1 => [0],
        2 => [1]
      },
      players: %{
        0 => %{
          name: "vanessa",
          ready: true
        },
        1 => %{
          name: "uwe",
          ready: false
        }
      }
    }

    # Flipping state back and forth results in no change
    new_state =
      game_state
      |> Lobby.set_ready(1, true)
      |> unwrap
      |> Lobby.set_ready(1, false)
      |> unwrap
    assert game_state == new_state

    new_state =
      game_state
      |> Lobby.set_ready(0, false)
      |> unwrap
      |> Lobby.set_ready(0, true)
      |> unwrap
    assert game_state == new_state

    # Setting any ready-value to false should result in it being false
    target_state = put_in(game_state.players[0].ready, false)
    new_state =
      game_state
      |> Lobby.set_ready(0, false)
      |> unwrap
      |> Lobby.set_ready(1, false)
      |> unwrap
    assert target_state == new_state

    # Setting any ready-value to true should result in it being true
    target_state = put_in(game_state, [:players, 1, :ready], true)
    new_state =
      game_state
      |> Lobby.set_ready(0, true)
      |> unwrap
      |> Lobby.set_ready(1, true)
      |> unwrap
    assert target_state == new_state
  end
end
