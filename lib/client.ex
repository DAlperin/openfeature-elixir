defmodule OpenfeatureElixir.Client do
  alias OpenfeatureElixir.{ClientGenServer}
  defstruct [:pid]

  def new() do
    new(nil)
  end

  def new(name) do
    case ClientGenServer.start_link(%OpenfeatureElixir.Config{name: name}) do
      {:ok, pid} ->
        GenServer.cast(
          OpenfeatureElixir.OpenfeatureManager,
          {:register_client, name || :default, pid}
        )

        %OpenfeatureElixir.Client{pid: pid}

      {:error, {:already_started, pid}} ->
        GenServer.cast(
          OpenfeatureElixir.OpenfeatureManager,
          {:register_client, name || :default, pid}
        )

        %OpenfeatureElixir.Client{pid: pid}
    end
  end

  def set_provider(%OpenfeatureElixir.Client{} = client, provider, args) do
    GenServer.call(client.pid, {:set_provider, provider, args})
    client
  end

  def get_boolean_value(%OpenfeatureElixir.Client{} = client, name, default)
      when is_boolean(default) do
    GenServer.call(client.pid, {:get_boolean_value, name, default})
  end

  def shutdown(%OpenfeatureElixir.Client{} = client) do
    GenServer.stop(client.pid)
  end
end
