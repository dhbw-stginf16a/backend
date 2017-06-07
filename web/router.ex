defmodule BrettProjekt.Router do
  use BrettProjekt.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BrettProjekt do
    pipe_through :api
  end
end
