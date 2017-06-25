defmodule BrettProjekt.Web.GameChannel do
  use Phoenix.Channel
  alias BrettProjekt.GameManager, as: GameManager

  @spec auth_token_valid?(String.t, GameManager.game_id) ::
    {:ok, struct} |
    {:error, :auth_token_invalid} |
    {:error, :auth_token_missing} |
    {:error, :auth_token_invalid}
  def auth_token_valid?(auth_token, game_id) do
    verification = Phoenix.Token.verify(BrettProjekt.Web.Endpoint,
                                        "user_auth", auth_token)
    case verification do
      {:ok, %{game_id: ^game_id} = payload} -> {:ok, payload}
      # Client shouldn't know game_id is valid for another game
      {:ok, _payload}                       -> {:error, :auth_token_invalid}
      {:error, :missing}                    -> {:error, :auth_token_missing}
      {:error, :expired}                    -> {:error, :auth_token_invalid}
      {:error, :invalid}                    -> {:error, :auth_token_invalid}
    end
  end

  @spec join(String.t, map, Phoenix.Socket.t) ::
    {:ok, Phoenix.Socket.t} |
    {:ok, map, Phoenix.Socket.t} |
    {:error, %{reason: any}}
  def join(channel, payload, socket) do
    game_id = String.replace_prefix channel, "game:", ""
    case auth_token_valid?(payload["auth_token"], game_id) do
      {:ok, _token_payload} -> {:ok, assign(socket, :game_id, game_id)}
      {:error, msg}         -> {:error, %{reason: msg}}
    end
  end
end
