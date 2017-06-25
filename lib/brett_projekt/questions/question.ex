defmodule BrettProjekt.Question do

  def evaluate_answer(questions_map, question_id, answer) do
    if Map.has_key?(questions_map, question_id) do
      evaluate_answer(questions_map[question_id], answer)
    else
      {:error, :question_not_found}
    end
  end

  def evaluate_answer(question, answer) do
    question_module = Map.get(question, :__struct__)

    if apply(question_module, :answer_valid?, [question, answer]) do
      if (apply(question_module, :answer_correct?, [question, answer])) do
        {:ok, true}
      else
        {:ok, false}
      end
    else
      {:error, :answer_invalid}
    end
  end
end

