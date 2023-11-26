defmodule OpenFeature.Providers.LaunchdarklyProvider.LDApi do
  alias OpenFeature.Providers.LaunchdarklyProvider
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
  def handle_call({:get, key, fallback, context}, _from, state) do
    IO.puts(inspect(context))
    {:reply, :ldclient.variation(key, context, fallback), state}
  end
end
