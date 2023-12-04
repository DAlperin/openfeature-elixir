defmodule OpenFeature do
  @moduledoc """
  [OpenFeature is an open specification that provides a vendor-agnostic,
  community-driven API for feature flagging that works with your favorite feature flag management tool.](https://openfeature.dev)

  ```elixir
    ldProviderConfig =
      OpenFeature.Providers.LaunchdarklyProvider.new()
      |> OpenFeature.Providers.LaunchdarklyProvider.set_sdk_key(System.get_env("LD_SDK_KEY"))

    OpenFeature.set_provider(
      OpenFeature.Providers.LaunchdarklyProvider,
      ldProviderConfig
    )

    globalContext =
      OpenFeature.Context.new_targeted_context("user-dov", %{
        kind: "user-other",
        name: "Dov"
      })

    OpenFeature.set_global_context(globalContext)

    # Create a client using the default provider
    client = OpenFeature.Client.new()

    value = OpenFeature.Client.get_boolean_value(client, "test-flag-for-demo", false
  ```
  """

  @doc """
  Set the global default provider for all clients which don't specify their own.
  """
  def set_provider(provider, args) do
    OpenFeature.Store.set_provider(provider, args)
  end

  @doc """
  Get the global default provider for all clients which don't specify their own.
  """
  def get_provider() do
    OpenFeature.Store.get_provider()
  end

  @doc """
    Set the global context for all clients.
  """
  def set_global_context(context) do
    OpenFeature.Store.set_global_context(context)
  end

  @doc """
    Get the global context for all clients.
  """
  def get_global_context() do
    OpenFeature.Store.get_global_context()
  end
end
