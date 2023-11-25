defmodule OpenfeatureElixirTest do
  use ExUnit.Case
  doctest OpenfeatureElixir

  test "launchdarkly provider" do
    {:ok, pid} = OpenfeatureElixir.init()

    # Configure the provider
    ldProviderConfig =
      OpenfeatureElixir.Providers.LaunchdarklyProvider.new()
      |> OpenfeatureElixir.Providers.LaunchdarklyProvider.set_sdk_key(
        System.get_env("LD_SDK_KEY")
      )

    OpenfeatureElixir.set_provider(
      OpenfeatureElixir.Providers.LaunchdarklyProvider,
      ldProviderConfig
    )

    # Create a client using the default provider
    client = OpenfeatureElixir.Client.new()

    assert OpenfeatureElixir.Client.get_boolean_value(client, "test-flag-for-demo", false) == true

    OpenfeatureElixir.Client.shutdown(client)

    OpenfeatureElixir.shutdown()
  end
end
