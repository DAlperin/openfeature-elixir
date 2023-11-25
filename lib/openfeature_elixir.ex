defmodule OpenfeatureElixir do
  @moduledoc """
  Documentation for `OpenfeatureElixir`.
  """

  def init() do
    OpenfeatureElixir.OpenfeatureManager.start_link()
  end

  def set_provider(provider, args) do
    GenServer.call(OpenfeatureElixir.OpenfeatureManager, {:set_default_provider, provider, args})
  end

  def shutdown() do
    GenServer.stop(OpenfeatureElixir.OpenfeatureManager)
  end

  def set_global_context(context) do
    GenServer.call(OpenfeatureElixir.OpenfeatureManager, {:set_global_context, context})
  end
end
