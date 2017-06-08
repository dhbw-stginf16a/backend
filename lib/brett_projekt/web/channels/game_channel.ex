defmodule BrettProjekt.Web.GameChannel do
  use Phoenix.Channel
  alias BrettProjekt.GameManager, as: GameManager

  def join(channel, payload, socket) do
    game_id = String.replace_prefix channel, "game:", ""
    cond do
      Map.get payload, "auth_token" == nil ->
        {:error, %{reason: "auth_token_missing"}}

      true ->
        case Phoenix.Token.verify(
          BrettProjekt.Web.Endpoint,
          "user_auth",
          Map.get(payload, "auth_token")
        ) do
          {:error, _reason} -> {:error, %{reason: "auth_token_invalid"}}
          {:ok, token_payload} ->
            cond do
              token_payload.game_id != game_id ->
                # Don't let the user know, that the token is valid for another game
                {:error, %{reason: "auth_token_invalid"}}
              true ->
                {:ok, socket}
            end
        end
    end
  end

  def handle_in("create_game", _payload, socket) do
    {:ok, game_id, _game} = GameManager.add_new_game :main_game_manager
    {:reply, {:ok, %{game_id: game_id}}, socket}
  end

end
