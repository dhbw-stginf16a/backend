defmodule BrettProjekt.Web.Router do
  use BrettProjekt.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BrettProjekt.Web do
    pipe_through :api
  end
end
