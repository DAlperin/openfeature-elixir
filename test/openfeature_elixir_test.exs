defmodule OpenFeatureTest do
  use ExUnit.Case
  doctest OpenFeature

  test "launchdarkly provider" do
    # Configure the provider
    ldProviderConfig =
      OpenFeature.Providers.LaunchdarklyProvider.new(System.get_env("LD_SDK_KEY"))

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

    # This other client points to the same underlying ets tables since a name isn't used
    _other = OpenFeature.Client.new()

    assert OpenFeature.Client.get_boolean_value(client, "test-flag-for-demo", false) == true
  end

  test "named client" do
    ldProviderConfig =
      OpenFeature.Providers.LaunchdarklyProvider.new(System.get_env("LD_SDK_KEY"))

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
    client = OpenFeature.Client.new(:named_client)

    assert OpenFeature.Client.get_boolean_value(client, "test-flag-for-demo", false) == true
  end
end
