defmodule OpenfeatureElixir.Client do
  alias OpenfeatureElixir.{ClientGenServer}

  def init_client() do
    ClientGenServer.start_link(%OpenfeatureElixir.Config{})
  end

  def init_client(name) do
    ClientGenServer.start_link(%OpenfeatureElixir.Config{name: name})
  end

  def set_provider(provider, args) do
    set_provider(ClientGenServer, provider, args)
  end

  def get_boolean_value(name, default) when is_boolean(default) do
    get_boolean_value(ClientGenServer, name, default)
  end

  def set_provider(pid, provider, args) do
    GenServer.call(pid, {:set_provider, provider, args})
  end

  def get_boolean_value(pid, name, default) when is_boolean(default) do
    GenServer.call(pid, {:get_boolean_value, name, default})
  end
end
