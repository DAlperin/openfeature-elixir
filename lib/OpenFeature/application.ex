defmodule OpenFeature.Application do
  use Application

  def start(_type, _args) do
    OpenFeature.Supervisor.start_link(nil)
  end
end
