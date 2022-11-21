defmodule LambentEx.Machine.Steps.Empty do
  @moduledoc false

  def step(id) do
    IO.puts("emptysteppy#{id}")
  end
end
