defmodule LaunchdarklyProvider do
  defstruct [:name, :sdk_key]

  def set_name(%LaunchdarklyProvider{} = opts, name) do
    Map.put(opts, :name, name)
  end

  def set_sdk_key(%LaunchdarklyProvider{} = opts, sdk_key) do
    Map.put(opts, :sdk_key, sdk_key)
  end

  def init(%LaunchdarklyProvider{name: name} = opts) do
    GenServer.start_link(LDApi, opts, name: name)
  end

  def init(%LaunchdarklyProvider{} = opts) do
    GenServer.start_link(LDApi, opts)
  end

  def get_boolean_value(pid, name, default) do
    GenServer.call(pid, {:get, name, default})
  end

  def terminate(pid) do
    GenServer.stop(pid)
  end
end
