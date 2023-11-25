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

  @impl true
  def init(%Config{} = args) do
    {:ok, provider} =
      GenServer.call(OpenfeatureElixir.OpenfeatureManager, {:get_default_provider})

    {:ok, Map.put(args, :provider, provider)}
  end

  @impl true
  def handle_call({:set_provider, provider, args}, _from, state) do
    {:ok, pid} = provider.init(args)
    state = Map.put(state, :provider, {provider, args, pid})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get_boolean_value, name, default}, _from, state) when is_boolean(default) do
    case Map.get(state, :provider) do
      {provider, _, pid} ->
        {:reply, provider.get_boolean_value(pid, name, default), state}

      _ ->
        {:reply, default, state}
    end
  end
end
