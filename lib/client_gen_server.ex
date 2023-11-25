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
  def terminate(_reason, %{:clients => clients}) do
    Enum.each(clients, fn client ->
      case client do
        {_, {provider, _, pid}} -> provider.terminate(pid)
        {_, {provider, _}} -> provider.terminate()
        _ -> nil
      end
    end)

    {:ok, %{}}
  end

  @impl true
  def init(%Config{} = args) do
    case args do
      %{name: name, metadata: nil} ->
        {:ok, Map.merge(args, %{:metadata => %{name: name}, :clients => %{}})}

      %{name: name, metadata: %{name: metadata_name}} when name != metadata_name ->
        {:error, "name and metadata.name must match"}

      _ ->
        {:error, :invalid_args}
    end
  end

  @impl true
  def handle_call({:set_provider, provider, args}, _from, state) do
    {:ok, pid} = provider.init(args)
    state = Map.put(state, :clients, Map.put(state.clients, :default, {provider, args, pid}))
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:set_provider, provider, args, clientName}, _from, state) do
    {:ok, pid} = provider.init(args)
    state = Map.put(state, :clients, Map.put(state.clients, clientName, {provider, args, pid}))
    {:reply, :ok, state}
  end

  def handle_call({:create_client, name}, _from, state) do
    default_provider = Map.get(state, :clients)[:default]
    {:reply, {:ok}, Map.put(state, :clients, Map.put(state.clients, name, default_provider))}
  end

  @impl true
  def handle_call(:get_metadata, _from, state) do
    {:reply, Map.get(state, :metadata), state}
  end

  @impl true
  def handle_call({:get_boolean_value, name, default}, _from, state) when is_boolean(default) do
    case Map.get(state, :clients)[:default] do
      {provider, _, pid} ->
        {:reply, provider.get_boolean_value(pid, name, default), state}

      _ ->
        {:reply, default, state}
    end
  end
end
