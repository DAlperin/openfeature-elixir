defmodule Client do
  def set_provider(pid, provider, args) do
    GenServer.call(pid, {:set_provider, provider, args})
  end

  def get_boolean_value(pid, name, default) do
    GenServer.call(pid, {:get_boolean_value, name, default})
  end
end
