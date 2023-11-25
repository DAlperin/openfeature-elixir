defmodule OpenfeatureElixir.ClientGenServer do
  use GenServer
  alias OpenfeatureElixir.{Config}

  def start_link(%Config{name: nil} = opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_link(%Config{} = opts) do
    GenServer.start_link(__MODULE__, opts, name: opts.name)
  end

  @impl true
  def terminate(_reason, %{:provider => provider}) do
    case provider do
      {provider, _, pid} ->
        provider.terminate(pid)

      _ ->
        :ok
    end

    {:ok, %{}}
  end

  def rollup_context(%OpenfeatureElixir.Config{global_context: nil, local_context: nil}) do
    OpenfeatureElixir.Context.new_targetless_context(%{})
  end

  def rollup_context(%OpenfeatureElixir.Config{global_context: nil, local_context: _}) do
    OpenfeatureElixir.Context.new_targetless_context(%{})
  end

  def rollup_context(%OpenfeatureElixir.Config{global_context: _, local_context: nil}) do
    OpenfeatureElixir.Context.new_targetless_context(%{})
  end

  def rollup_context(nil, nil) do
    OpenfeatureElixir.Context.new_targetless_context(%{})
  end

  def rollup_context(nil, second) do
    second
  end

  def rollup_context(first, nil) do
    first
  end

  def rollup_context(%OpenfeatureElixir.Context{} = first, %OpenfeatureElixir.Context{} = second) do
    if is_nil(first.key) && is_nil(second.key) do
      OpenfeatureElixir.Context.new_targetless_context(Map.merge(first.body, second.body))
    else
      OpenfeatureElixir.Context.new_targeted_context(
        first.key || second.key,
        Map.merge(first.body, second.body)
      )
    end
  end

  def rollup_context(first, nil, nil) do
    first
  end

  def rollup_context(nil, second, nil) do
    second
  end

  def rollup_context(nil, nil, third) do
    third
  end

  def rollup_context(first, second, nil) do
    rollup_context(first, second)
  end

  def rollup_context(first, nil, third) do
    rollup_context(first, third)
  end

  def rollup_context(nil, second, third) do
    rollup_context(second, third)
  end

  def rollup_context(
        %OpenfeatureElixir.Context{} = first,
        %OpenfeatureElixir.Context{} = second,
        %OpenfeatureElixir.Context{} = third
      ) do
    rollup_context(first, second) |> rollup_context(third)
  end

  def get_bool(state, name, default, context) do
    context = rollup_context(state.global_context, state.local_context, context)

    case Map.get(state, :provider) do
      {provider, _, pid} ->
        {:reply, provider.get_boolean_value(pid, name, default, context), state}

      _ ->
        {:reply, default, state}
    end
  end

  @impl true
  def init(%Config{} = args) do
    {:ok, provider} =
      GenServer.call(OpenfeatureElixir.OpenfeatureManager, {:get_default_provider})

    {:ok, global_context} =
      GenServer.call(OpenfeatureElixir.OpenfeatureManager, {:get_global_context})

    args =
      Map.merge(args, %{
        provider: provider,
        global_context: global_context,
        local_context: nil
      })

    {:ok, args}
  end

  @impl true
  def handle_call({:set_provider, provider, args}, _from, state) do
    {:ok, pid} = provider.init(args)
    state = Map.put(state, :provider, {provider, args, pid})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get_boolean_value, name, default}, _from, state)
      when is_boolean(default) do
    get_bool(state, name, default, OpenfeatureElixir.Context.new_targetless_context(%{}))
  end

  @impl true
  def handle_call({:get_boolean_value, name, default, context}, _from, state)
      when is_boolean(default) do
    get_bool(state, name, default, context)
  end

  @impl true
  def handle_call({:get_string_value, name, default}, _from, state) when is_binary(default) do
    case Map.get(state, :provider) do
      {provider, _, pid} ->
        {:reply, provider.get_string_value(pid, name, default), state}

      _ ->
        {:reply, default, state}
    end
  end
end
