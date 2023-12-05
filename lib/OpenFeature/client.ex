defmodule OpenFeature.Client do
  @moduledoc """
  Client for OpenFeature.
  """
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

  defp get_client_name(%OpenFeature.Client{name: name}) do
    name || __MODULE__
  end

  def get_provider(%OpenFeature.Client{} = client) do
    # Check if we have a provider already
    case :ets.lookup(get_client_name(client), "provider") do
      [{_, {provider, args}}] ->
        {provider, args}

      # Check if we have a default provider
      _ ->
        case OpenFeature.get_provider() do
          {provider, args} ->
            {provider, args}

          _ ->
            nil
        end
    end
  end

  defp get_bool(%OpenFeature.Client{} = client, name, default, context) do
    case get_provider(client) do
      {provider, args} ->
        context =
          Context.rollup_context(OpenFeature.get_global_context(), get_context(client), context)

        provider.get_boolean_value(args, name, default, context)

      _ ->
        default
    end
  end

  defp get_string(%OpenFeature.Client{} = client, name, default, context) do
    case get_provider(client) do
      {provider, args} ->
        context =
          Context.rollup_context(OpenFeature.get_global_context(), get_context(client), context)

        provider.get_string_value(args, name, default, context)

      _ ->
        default
    end
  end

  defp get_number(%OpenFeature.Client{} = client, name, default, context) do
    case get_provider(client) do
      {provider, args} ->
        context =
          Context.rollup_context(OpenFeature.get_global_context(), get_context(client), context)

        provider.get_number_value(args, name, default, context)

      _ ->
        default
    end
  end

  def set_context(%OpenFeature.Client{} = client, context) do
    :ets.insert(get_client_name(client), {"local_context", context})
    client
  end

  def get_context(%OpenFeature.Client{} = client) do
    case :ets.lookup(get_client_name(client), "local_context") do
      [{_, context}] ->
        context

      _ ->
        Context.new_targetless_context(%{})
    end
  end

  def set_provider(%OpenFeature.Client{} = client, provider, args) do
    {:ok} = provider.init(args)
    :ets.insert(get_client_name(client), {"provider", {provider, args}})
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

  def get_number_value(%OpenFeature.Client{} = client, name, default)
      when is_number(default) do
    get_number(client, name, default, Context.new_targetless_context(%{}))
  end

  def get_number_value(
        %OpenFeature.Client{} = client,
        name,
        default,
        %OpenFeature.Context{} = context
      )
      when is_number(default) do
    get_number(client, name, default, context)
  end
end
