defmodule OpenFeature.OpenfeatureManager do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    state = %{clients: %{}, default_provider: nil, global_context: nil}
    {:ok, state}
  end

  @impl true
  def handle_call({:set_default_provider, provider, args}, _from, state) do
    {:ok, pid} = provider.init(args)
    state = Map.put(state, :default_provider, {provider, args, pid})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get_default_provider}, _from, state) do
    {:reply, {:ok, Map.get(state, :default_provider)}, state}
  end

  @impl true
  def handle_call({:set_global_context, %OpenFeature.Context{} = context}, _from, state) do
    {:reply, :ok, Map.put(state, :global_context, context)}
  end

  @impl true
  def handle_call({:get_global_context}, _from, state) do
    {:reply, {:ok, Map.get(state, :global_context)}, state}
  end

  @impl true
  def handle_cast({:register_client, name, pid}, state) do
    {:noreply, Map.put(state, :clients, Map.put(state.clients, name, pid))}
  end

  @impl true
  def terminate(_reason, state) do
    Enum.each(state.clients, fn {_, pid} -> GenServer.stop(pid) end)
  end
end
