defmodule OpenFeature.Store do
  use GenServer

  @table_name :openfeature

  def worker_spec() do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :permanent,
      type: :worker
    }
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    cond do
      :ets.whereis(@table_name) != :undefined ->
        IO.puts("OpenFeature already initialized")
        nil

      true ->
        :ets.new(@table_name, [:named_table, read_concurrency: true])
    end

    {:ok, :ok}
  end

  def set_provider(provider, args) do
    GenServer.call(__MODULE__, {:set_provider, provider, args})
  end

  def get_provider() do
    [{_, provider}] = :ets.lookup(@table_name, "default_provider")
    provider
  end

  def set_global_context(context) do
    GenServer.call(__MODULE__, {:set_global_context, context})
  end

  def get_global_context() do
    [{_, context}] = :ets.lookup(@table_name, "global_context")
    context
  end

  @impl true
  def handle_call({:set_provider, provider, args}, _from, state) do
    {:ok, pid} = provider.init(args)
    :ets.insert(@table_name, {"default_provider", {provider, args, pid}})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:set_global_context, context}, _from, state) do
    :ets.insert(@table_name, {"global_context", context})
    {:reply, :ok, state}
  end
end
