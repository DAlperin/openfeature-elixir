defmodule OpenFeature.Client do
  alias OpenFeature.{Context}
  defstruct [:name, :pid, :local_context]

  def new() do
    new(nil)
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

  def get_provider(%OpenFeature.Client{name: client_name}) do
    # Check if we have a provider already
    case :ets.lookup(client_name || __MODULE__, "provider") do
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

  defp get_bool(%OpenFeature.Client{} = client, name, default, context) do
    case get_provider(client) do
      {provider, pid} ->
        context =
          Context.rollup_context(OpenFeature.get_global_context(), get_context(client), context)

        provider.get_boolean_value(pid, name, default, context)

      _ ->
        default
    end
  end

  defp get_string(%OpenFeature.Client{} = client, name, default, context) do
    case get_provider(client) do
      {provider, pid} ->
        context =
          Context.rollup_context(OpenFeature.get_global_context(), get_context(client), context)

        provider.get_string_value(pid, name, default, context)

      _ ->
        default
    end
  end

  def set_context(%OpenFeature.Client{} = client, context) do
    :ets.insert(client.name || __MODULE__, {"local_context", context})
    client
  end

  def get_context(%OpenFeature.Client{} = client) do
    case :ets.lookup(client.name || __MODULE__, "local_context") do
      [{_, context}] ->
        context

      _ ->
        Context.new_targetless_context(%{})
    end
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

  def get_boolean_value(
        %OpenFeature.Client{} = client,
        name,
        default,
        %OpenFeature.Context{} = context
      )
      when is_boolean(default) do
    get_bool(client, name, default, context)
  end

  def get_string_value(%OpenFeature.Client{} = client, name, default)
      when is_binary(default) do
    get_string(client, name, default, Context.new_targetless_context(%{}))
  end

  def get_string_value(
        %OpenFeature.Client{} = client,
        name,
        default,
        %OpenFeature.Context{} = context
      )
      when is_binary(default) do
    get_string(client, name, default, context)
  end
end
