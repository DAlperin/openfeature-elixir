defmodule OpenFeature.Providers.LaunchdarklyProvider.LDApi do
  alias OpenFeature.Providers.LaunchdarklyProvider
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def wait_for_initialized(timeout, tag) do
    wait_for_initialized(tag, System.os_time(:millisecond), false, timeout)
  end

  def wait_for_initialized(tag, started_at, false, timeout) do
    elapsed = System.os_time(:millisecond) - started_at
    inited = :ldclient.initialized(tag)
    wait_for_initialized(tag, started_at, inited || elapsed > timeout, timeout)
  end

  def wait_for_initialized(_tag, _started_at, true, _timeout) do
    :ok
  end

  @impl true
  def init(%LaunchdarklyProvider{sdk_key: sdk_key}) do
    :ldclient.start_instance(
      String.to_charlist(sdk_key),
      :default,
      %{
        :http_options => %{
          :tls_options => :ldclient_config.tls_basic_options()
        }
      }
    )

    wait_for_initialized(5000, :default)

    {:ok, %{}}
  end

  @impl true
  def init(%LaunchdarklyProvider{sdk_key: sdk_key, name: name}) do
    :ldclient.start_instance(
      String.to_charlist(sdk_key),
      name,
      %{
        :http_options => %{
          :tls_options => :ldclient_config.tls_basic_options()
        }
      }
    )

    wait_for_initialized(5000, name)

    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key, fallback, context}, _from, state) do
    {:reply, :ldclient.variation(key, context, fallback), state}
  end
end
