defmodule OpenFeature.Client do
  alias OpenFeature.{Context}
  defstruct [:name, :pid, :local_context]

  def new() do
    new(nil)
  end

  def get_provider(%OpenFeature.Client{} = client) do
    # Check if we have a provider already
    case :ets.lookup(client.name || __MODULE__, "provider") do
      [{_, {provider, _, pid}}] ->
        {provider, pid}

      # Check if we have a default provider
      [] ->
        case OpenFeature.get_provider() do
          {provider, _, pid} ->
            {provider, pid}

          _ ->
            nil
        end

      _ ->
        nil
    end
  end

  def get_bool(%OpenFeature.Client{} = client, name, default, context) do
    context =
      Context.rollup_context(OpenFeature.get_global_context(), client.local_context, context)

    case get_provider(client) do
      {provider, pid} ->
        provider.get_boolean_value(pid, name, default, context)

      _ ->
        default
    end
  end

  def get_string(%OpenFeature.Client{} = client, name, default, context) do
    context =
      Context.rollup_context(OpenFeature.get_global_context(), client.local_context, context)

    case get_provider(client) do
      {provider, pid} ->
        provider.get_string_value(pid, name, default, context)

      _ ->
        default
    end
  end

  def new(name) do
    case :ets.whereis(name || __MODULE__) do
      :undefined ->
        :ets.new(name || __MODULE__, [:named_table, read_concurrency: true])

      _ ->
        nil
    end

    %OpenFeature.Client{
      name: name,
      local_context: nil
    }
  end

  def set_provider(%OpenFeature.Client{} = client, provider, args) do
    {:ok, pid} = provider.init(args)
    :ets.insert(client.name || __MODULE__, {"provider", {provider, args, pid}})
    client
  end

  def get_boolean_value(%OpenFeature.Client{} = client, name, default)
      when is_boolean(default) do
    get_bool(client, name, default, Context.new_targetless_context(%{}))
  end
end
