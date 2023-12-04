defmodule OpenFeature.Application do
  @moduledoc """
  The top-level application for OpenFeature.
  """
  use Application

  def start(_type, _args) do
    OpenFeature.Supervisor.start_link(nil)
  end
end
