defmodule BrettProjekt.Game.Player do
  use GenServer

  @enforce_keys [:id, :name]
  defstruct [
    :id,
    :name,
    :team,
    {:ready, false},
    {:roles, []}
  ]

  # ---------- Client API ----------
  def create(player_id, name, roles \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{
      id: player_id,
      name: name,
      roles: roles
    })
  end

  def get_id(player) do
    GenServer.call(player, :get_id)
  end

  def get_name(player) do
    GenServer.call(player, :get_name)
  end

  def set_team(player, team) do
    GenServer.call(player, {:set_team, team})
  end

  def get_team(player) do
    GenServer.call(player, :get_team)
  end

  def add_role(player, role) do
    GenServer.call(player, {:add_role, role})
  end

  def get_roles(player) do
    GenServer.call(player, :get_roles)
  end

  def has_role?(player, role) do
    Enum.member? get_roles(player), role
  end

  def ready?(player) do
    GenServer.call(player, :get_ready)
  end

  def set_ready(player, ready) do
    GenServer.call(player, {:set_ready, ready})
  end

  # ---------- Server API ----------
  def handle_call(:get_id, _form, state) do
    {:reply, state.id, state}
  end

  def handle_call(:get_name, _from, state) do
    {:reply, state.name, state}
  end

  def handle_call(:get_team, _from, state) do
    {:reply, state.team, state}
  end

  def handle_call({:set_team, team}, _from, state) do
    {:reply, :ok, %{state | team: team}}
  end

  def handle_call({:add_role, role}, _from, state) do
    {:reply, :ok, %{state | roles: [ role | state.roles ]}}
  end

  def handle_call(:get_roles, _from, state) do
    {:reply, state.roles, state}
  end

  def handle_call(:get_ready, _from, state) do
    {:reply, state.ready, state}
  end

  def handle_call({:set_ready, ready}, _from, state) do
    {:reply, :ok, %{state | ready: ready}}
  end
end

