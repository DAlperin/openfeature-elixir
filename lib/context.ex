defmodule OpenfeatureElixir.Context do
  defstruct [:body, key: ""]

  def new_targetless_context(body) do
    %OpenfeatureElixir.Context{body: body}
  end

  def new_targeted_context(key, body) do
    %OpenfeatureElixir.Context{key: key, body: body}
  end
end
