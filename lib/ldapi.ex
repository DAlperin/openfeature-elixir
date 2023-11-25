defmodule LDApi do
  use GenServer

  def wait_for_initalized() do
    case :ldclient.initialized(:default) do
      true ->
        :ok

      false ->
        :timer.sleep(100)
        wait_for_initalized()
    end
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

    wait_for_initalized()

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

    wait_for_initalized()

    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key, fallback}, _from, state) do
    {:reply, :ldclient.variation(key, :ldclient_context.new(""), fallback), state}
  end
end
