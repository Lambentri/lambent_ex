defmodule LambentEx.Machine.Steps do
  @doc """
  Steps the machine Forward
  """
  @callback step() :: {:ok, term} | {:error, String.t()}

  @doc """
  Read the machine state
  """
  @callback read() :: [float]
end
