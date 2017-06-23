defmodule BrettProjekt.Game.RoundPreparationStateTransformation do
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep
  alias BrettProjekt.Game.Round, as: Round

  defp all_categories_assigned?(state) do
    Enum.all?(state.teams, fn {_id, team} ->
      Enum.all?(team.categories, fn {_cat_id, answerer} -> answerer != nil end)
    end)
  end

  def transform(%RoundPrep{} = state) do
    if all_categories_assigned?(state) do
      {:ok, force_transform(state)}
    else
      {:error, :not_all_categories_assigned}
    end
  end

  defp assign_questions(players, questions, categories) do
    players
    |> Enum.map(fn {player_id, name} ->
      {player_id, %{
        name: name,
        questions: get_player_questions(player_id, questions, categories)
      }}
    end)
    |> Enum.into(%{})
  end

  defp get_player_questions(player_id, questions, categories) do
    questions =
      Enum.filter_map(categories,
        fn {_category_id, p_id} ->
          player_id == p_id
        end,
        fn {category_id, _p_id} ->
          {questions[category_id] |> Map.keys |> hd, nil}
        end)
      |> Enum.into(%{})

    [questions]  # first round in the list of rounds
  end

  # TODO get real questions
  defp get_team_questions(team_id) do
    questions = %{
      0 => %{
        1 => %{
          4 => :question
        },
        2 => %{
          6 => :question
        },
        5 => %{
          9 => :question
        },
      },
      1 => %{
        1 => %{
          2 => :question
        },
        2 => %{
          6 => :question
        },
        5 => %{
          19 => :question
        }
      },
      2 => %{
        1 => %{
          1 => :question
        },
        2 => %{
          42 => :question
        },
        5 => %{
          28 => :question
        }
      }
    }
    questions[team_id]
  end

  def force_transform(state) do
    teams =
      state.teams
      |> Enum.map(fn {team_id, %{players: players, categories: categories}} ->
        team_questions = get_team_questions(team_id)
        {team_id, %{
          players: assign_questions(players, team_questions, categories),
          categories: categories
        }}
      end)
      |> Enum.into(%{})

    %Round{teams: teams}
  end

end
