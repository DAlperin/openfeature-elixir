defmodule OpenFeature do
  @moduledoc """
  Documentation for `OpenFeature`.
  """

  def init() do
    cond do
      :ets.whereis(:openfeature) != :undefined ->
        IO.puts("OpenFeature already initialized")
        nil

      true ->
        :ets.new(:openfeature, [:named_table, read_concurrency: true])
    end
  end

  def set_provider(provider, args) do
    {:ok, pid} = provider.init(args)
    :ets.insert(:openfeature, {"default_provider", {provider, args, pid}})
  end

  def get_provider() do
    [{_, provider}] = :ets.lookup(:openfeature, "default_provider")
    provider
  end

  def set_global_context(context) do
    :ets.insert(:openfeature, {"global_context", context})
  end

  def get_global_context() do
    [{_, context}] = :ets.lookup(:openfeature, "global_context")
    context
  end
end
