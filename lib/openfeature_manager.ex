defmodule OpenfeatureElixir.OpenfeatureManager do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(args) do
    {:ok, args}
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
end
