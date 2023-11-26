defmodule OpenFeature.Client do
  alias OpenFeature.{ClientGenServer}
  defstruct [:pid]

  def new() do
    new(nil)
  end

  def new(name) do
    case ClientGenServer.start_link(%OpenFeature.Config{name: name}) do
      {:ok, pid} ->
        GenServer.cast(
          OpenFeature.OpenfeatureManager,
          {:register_client, name || :default, pid}
        )

        %OpenFeature.Client{pid: pid}

      {:error, {:already_started, pid}} ->
        GenServer.cast(
          OpenFeature.OpenfeatureManager,
          {:register_client, name || :default, pid}
        )

        %OpenFeature.Client{pid: pid}
    end
  end

  def set_provider(%OpenFeature.Client{} = client, provider, args) do
    GenServer.call(client.pid, {:set_provider, provider, args})
    client
  end

  def get_boolean_value(%OpenFeature.Client{} = client, name, default)
      when is_boolean(default) do
    GenServer.call(client.pid, {:get_boolean_value, name, default})
  end

  def shutdown(%OpenFeature.Client{} = client) do
    GenServer.stop(client.pid)
  end
end
