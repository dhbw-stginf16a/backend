defmodule BrettProjekt.Game.Round do

  defstruct [
    {:teams, %{}}
  ]

  def answer_questions(game_state, player_id, answers) do
    cond do
      not player_existent?(game_state, player_id) ->
        {:error, :player_nonexistent}
      not all_questions_available?(game_state, player_id, answers) ->
        {:error, :question_unavailable}
      true -> {:ok, force_answer_question(game_state, player_id, answers)}
    end
  end

  defp teamid_of_player(game_state, player_id) do
    game_state.teams
    |> Enum.find_value(fn {id, team} ->
      if team.players[player_id] != nil, do: id
    end)
  end

  @spec all_questions_available?(any, any, any) :: boolean
  defp all_questions_available?(game_state, player_id, answers) do
    question_ids = MapSet.new(Map.keys(answers))
    team_id = teamid_of_player(game_state, player_id)
    if team_id == nil do
      false
    else
      game_state.teams[team_id]
      |> Map.get(:players)
      |> Map.get(player_id)
      |> Map.get(:questions)
      |> hd  # current round is first in the list
      |> Map.keys
      |> MapSet.new
      |> (&MapSet.subset?(question_ids, &1)).()
    end
  end

  @spec player_existent?(any, any) :: boolean
  defp player_existent?(game_state, player_id) do
    nil != teamid_of_player(game_state, player_id)
  end

  defp force_answer_question(game_state, player_id, answers) do
    team_id = teamid_of_player(game_state, player_id)
    player_questions =
      game_state.teams[team_id].players[player_id].questions
    current_questions = hd(player_questions)

    new_current_questions =
      for {question_id, _answer} <- current_questions, into: %{} do
        if Map.has_key?(answers, question_id) do
          {question_id, answers[question_id]}
        else
          {question_id, nil}
        end
      end

    new_player_questions =
      player_questions
      |> List.replace_at(0, new_current_questions)

    put_in(game_state.teams[team_id].players[player_id].questions,
           new_player_questions)
  end
end
