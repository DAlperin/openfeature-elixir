defmodule OpenfeatureElixirTest do
  use ExUnit.Case
  doctest OpenfeatureElixir

  test "launchdarkly provider" do
    {:ok, pid} = ClientGenServer.start_link(%OpenfeatureElixir.Config{})

    # Configure the provider
    ldProviderConfig =
      %LaunchdarklyProvider{}
      |> LaunchdarklyProvider.set_sdk_key(System.get_env("LD_SDK_KEY"))

    Client.set_provider(pid, LaunchdarklyProvider, ldProviderConfig)

    # This test is specific to my account right now, fight me :)
    assert Client.get_boolean_value(pid, "test-flag-for-demo", false) == true

    GenServer.stop(pid, :normal)
  end
end
