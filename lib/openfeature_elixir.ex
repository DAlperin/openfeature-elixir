defmodule OpenFeature do
  @moduledoc """
  Documentation for `OpenFeature`.
  """

  def init() do
    OpenFeature.OpenfeatureManager.start_link()
  end

  def set_provider(provider, args) do
    GenServer.call(OpenFeature.OpenfeatureManager, {:set_default_provider, provider, args})
  end

  def shutdown() do
    GenServer.stop(OpenFeature.OpenfeatureManager)
  end

  def set_global_context(context) do
    GenServer.call(OpenFeature.OpenfeatureManager, {:set_global_context, context})
  end
end
