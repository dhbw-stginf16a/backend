defmodule BrettProjekt.GameTest do
  use ExUnit.Case, async: false
  doctest BrettProjekt.Game
  alias BrettProjekt.Game, as: Game
  alias BrettProjekt.Game.Player, as: Player

  test "create a new game" do
    {:ok, game} = Game.create System.unique_integer
    assert is_pid game
  end

  test "get the game-id of an existing game" do
    game_id = System.unique_integer
    {:ok, game} = Game.create game_id

    assert game_id == Game.get_id(game)
  end

  test "add a new player to a game" do
    {:ok, game} = Game.create System.unique_integer
    assert length(Map.values(Game.get_players game)) == 0

    {:ok, player, players} = Game.add_new_player game, "peter"
    assert players == Game.get_players(game)

    assert Player.get_name(player) == "peter"
    assert Player.get_id(player) == 0
    assert Player.has_role?(player, :admin) == true
    assert Player.get_team(player) == nil
    assert Player.ready?(player) == false

    players = Game.get_players game
    assert length(Map.values(players)) == 1
    assert Player.get_id(players[0]) == Player.get_id(player)
  end

  test "add a player with a name of non-printable characters" do
    {:ok, game} = Game.create System.unique_integer

    non_printable_name = <<239, 191, 191, 57, 82, 85, 71, 85>>
    assert {:error, :name_invalid} == Game.add_new_player(game, non_printable_name)
  end

  test "add a player with a too short / long name" do
    {:ok, game} = Game.create System.unique_integer

    short_name = "a"
    long_name = "abcdefghijklmnopqrstuvwxyz"

    assert {:error, :name_invalid} == Game.add_new_player(game, short_name)
    assert {:error, :name_invalid} == Game.add_new_player(game, long_name)
  end

  test "add two players with identical names" do
    {:ok, game} = Game.create System.unique_integer

    name = "david"
    {:ok, _player, _players} = Game.add_new_player(game, name)
    assert {:error, :name_conflict} == Game.add_new_player(game, name)
  end

  test "disable join" do
    {:ok, game} = Game.create System.unique_integer
    assert Game.join_enabled?(game) == true

    Game.disable_join game
    assert Game.join_enabled?(game) == false
  end

  test "add a player while joining is disabled" do
    {:ok, game} = Game.create System.unique_integer
    Game.disable_join game

    assert {:error, :joining_disabled} == Game.add_new_player(game, "eric")
  end
end
