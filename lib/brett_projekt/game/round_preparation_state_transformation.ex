defmodule BrettProjekt.Game.RoundPreparationStateTransformation do
  alias BrettProjekt.Game.RoundPreparation, as: RoundPrep
  alias BrettProjekt.Game.Round, as: Round

  defp all_categories_assigned?(state) do
    Enum.all?(state.teams, fn {_id, team} ->
      Enum.all?(team.categories, fn {_cat_id, answerer} -> answerer != nil end)
    end)
  end

  def transform(%RoundPrep{} = state, questions) do
    if all_categories_assigned?(state) do
      {:ok, force_transform(state, questions)}
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
      categories
      |> Enum.filter_map(
        fn {_category_id, p_id} ->
          player_id == p_id
        end,
        fn {category_id, _p_id} ->
          {questions[category_id] |> Map.keys |> hd, nil}
        end)
      |> Enum.into(%{})

    [questions]  # first round in the list of rounds
  end

  defp force_transform(state, questions) do
    teams =
      state.teams
      |> Enum.map(fn {team_id, %{players: players, categories: categories}} ->
        {team_id, %{
          players: assign_questions(players, questions[team_id], categories),
          categories: categories
        }}
      end)
      |> Enum.into(%{})

    %Round{teams: teams}
  end

end
