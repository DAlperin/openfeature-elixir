defmodule OpenFeature.Supervisor do
  @moduledoc """
  The top-level supervisor for OpenFeature.
  """
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Supervisor.init(children(), strategy: :one_for_one)
  end

  defp children do
    [
      OpenFeature.Store.child_spec()
    ]
  end
end
