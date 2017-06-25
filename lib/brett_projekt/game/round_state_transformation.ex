defmodule BrettProjekt.Game.RoundStateTransformation do
  alias BrettProjekt.Game.Round, as: Round
  alias BrettProjekt.Game.RoundEvaluation, as: RoundEval
  alias BrettProjekt.Question, as: Question

  def transform(%Round{} = state, questions) do
    teams =
      for {team_id, team} <- state.teams, into: %{} do
        players =
          for {player_id, player} <- team.players, into: %{} do
            answers = hd(player.questions)
            evaluated = evaluate_player_questions(questions, answers)
            new_player = put_in(player.questions,
                                List.replace_at(player.questions,
                                                0, evaluated))
            {player_id, new_player}
          end
        {team_id, %{team | players: players}}
      end

    {:ok, %RoundEval{teams: teams}}
  end

  defp evaluate_player_questions(questions, answers) do
    for {question_id, answer} <- answers, into: %{} do
      correct? =
        case Question.evaluate_answer(questions, question_id, answer) do
          {:ok, true} -> true
          {:ok, false} -> false
          {:error, :question_not_found} -> false
          {:error, :answer_invalid} -> false
        end

      correct_answer =
        case Question.correct_answer(questions, question_id) do
          {:error, :question_not_found} -> nil
          {:ok, answer} -> answer
        end

      {question_id, %{
        correct_answer: correct_answer,
        answer: answer,
        score: (if correct?, do: 1, else: 0)
      }}
    end
  end
end
