defmodule OpenfeatureElixirTest do
  use ExUnit.Case
  doctest OpenfeatureElixir

  test "launchdarkly provider" do
    {:ok, pid} = OpenfeatureElixir.Client.init_client()

    # Configure the provider
    ldProviderConfig =
      OpenfeatureElixir.Providers.LaunchdarklyProvider.new()
      |> OpenfeatureElixir.Providers.LaunchdarklyProvider.set_sdk_key(
        System.get_env("LD_SDK_KEY")
      )

    # Set the default provider
    OpenfeatureElixir.Client.set_provider(
      OpenfeatureElixir.Providers.LaunchdarklyProvider,
      ldProviderConfig
    )

    # This test is specific to my account right now, fight me :)
    assert OpenfeatureElixir.Client.get_boolean_value("test-flag-for-demo", false) == true

    GenServer.stop(pid, :normal)
  end
end
