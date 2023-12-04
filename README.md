# OpenfeatureElixir

[OpenFeature is an open specification that provides a vendor-agnostic, community-driven API for feature flagging that works with your favorite feature flag management tool.](https://openfeature.dev)

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

## Installation

```elixir
def deps do
  [
    {:openfeature_elixir, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/openfeature_elixir>.
