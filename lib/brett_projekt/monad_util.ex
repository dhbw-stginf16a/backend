defmodule BrettProjekt.MonadUtil do
  # TODO think about replacing this with bind
  def unwrap({:ok, val}), do: val
  def unwrap(val), do: raise "Cannot unwrap #{inspect val}"
end
