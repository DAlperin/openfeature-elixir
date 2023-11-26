defmodule OpenFeature.Providers.LaunchdarklyProvider do
  alias OpenFeature.Providers.LaunchdarklyProvider
  defstruct [:name, :sdk_key]

  def new() do
    %OpenFeature.Providers.LaunchdarklyProvider{}
  end

  def set_name(%LaunchdarklyProvider{} = opts, name) do
    Map.put(opts, :name, name)
  end

  def set_sdk_key(%LaunchdarklyProvider{} = opts, sdk_key) when is_binary(sdk_key) do
    Map.put(opts, :sdk_key, sdk_key)
  end

  def init(%LaunchdarklyProvider{name: name} = opts) do
    GenServer.start_link(LaunchdarklyProvider.LDApi, opts, name: name)
  end

  def init(%LaunchdarklyProvider{} = opts) do
    GenServer.start_link(LaunchdarklyProvider.LDApi, opts)
  end

  def get_boolean_value(pid, name, default, context) when is_boolean(default) do
    GenServer.call(pid, {:get, name, default, ld_context_from_context(context)})
  end

  def get_string_value(pid, name, default, context) when is_binary(default) do
    GenServer.call(pid, {:get, name, default, ld_context_from_context(context)})
  end

  def ld_context_from_context(%OpenFeature.Context{} = context) do
    :ldclient_context.new_from_map(
      Map.merge(
        %{
          :key => context.key
        },
        context.body
      )
    )
  end

  def terminate(pid) do
    GenServer.stop(pid)
  end
end
