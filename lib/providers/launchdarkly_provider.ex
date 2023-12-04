defmodule OpenFeature.Providers.LaunchdarklyProvider do
  @moduledoc """
  A provider for Launchdarkly.
  """
  @behaviour OpenFeature.Provider
  alias OpenFeature.Providers.LaunchdarklyProvider
  defstruct [:name, :sdk_key]

  # def child_spec(opts) do
  #   %{
  #     id: OpenFeature.Providers.LaunchdarklyProvider.LDApi,
  #     start: {OpenFeature.Providers.LaunchdarklyProvider.LDApi, :init, [opts]},
  #     restart: :permanent,
  #     type: :worker
  #   }
  # end

  def new(sdk_key) do
    %OpenFeature.Providers.LaunchdarklyProvider{
      name: String.to_atom(UUID.uuid4()),
      sdk_key: sdk_key
    }
  end

  def set_name(%LaunchdarklyProvider{} = opts, name) do
    Map.put(opts, :name, name)
  end

  def set_sdk_key(%LaunchdarklyProvider{} = opts, sdk_key) when is_binary(sdk_key) do
    Map.put(opts, :sdk_key, sdk_key)
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

  def init(%LaunchdarklyProvider{sdk_key: sdk_key, name: nil}) do
    init(%LaunchdarklyProvider{sdk_key: sdk_key, name: :default})
  end

  def init(%LaunchdarklyProvider{sdk_key: sdk_key, name: name}) do
    case :ldclient.start_instance(
           String.to_charlist(sdk_key),
           name,
           %{
             :http_options => %{
               :tls_options => :ldclient_config.tls_basic_options()
             }
           }
         ) do
      :ok ->
        :ok

      {:error, :already_started, _} ->
        :ok
    end

    wait_for_initialized(5000, name)

    {:ok}
  end

  def get_boolean_value(
        %OpenFeature.Providers.LaunchdarklyProvider{} = opts,
        name,
        default,
        context
      )
      when is_boolean(default) do
    get(opts.name || :default, name, default, ld_context_from_context(context))
  end

  def get_string_value(
        %OpenFeature.Providers.LaunchdarklyProvider{} = opts,
        name,
        default,
        context
      )
      when is_binary(default) do
    get(opts.name || :default, name, default, ld_context_from_context(context))
  end

  defp get(pname, key, fallback, context) do
    :ldclient.variation(key, context, fallback, pname)
  end

  defp ld_context_from_context(%OpenFeature.Context{} = context) do
    :ldclient_context.new_from_map(
      Map.merge(
        %{
          :key => context.key
        },
        context.body
      )
    )
  end
end
