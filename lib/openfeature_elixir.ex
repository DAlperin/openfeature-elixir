defmodule OpenFeature do
  @moduledoc """
  Documentation for `OpenFeature`.
  """

  def set_provider(provider, args) do
    OpenFeature.Store.set_provider(provider, args)
  end

  def get_provider() do
    OpenFeature.Store.get_provider()
  end

  def set_global_context(context) do
    OpenFeature.Store.set_global_context(context)
  end

  def get_global_context() do
    OpenFeature.Store.get_global_context()
  end
end
