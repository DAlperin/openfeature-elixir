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

    globalContext =
      OpenfeatureElixir.Context.new_targeted_context("user-dov", %{
        kind: "user-other",
        name: "Dov"
      })

    OpenfeatureElixir.set_global_context(globalContext)

    # Create a client using the default provider
    client = OpenfeatureElixir.Client.new()

    # This other client points to the same underlying genserver since a name isn't used
    other = OpenfeatureElixir.Client.new()

    assert OpenfeatureElixir.Client.get_boolean_value(client, "test-flag-for-demo", false) == true

    OpenfeatureElixir.shutdown()
  end
end
