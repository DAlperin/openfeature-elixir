defmodule OpenFeature.Context do
  defstruct [:body, key: ""]

  def new_targetless_context(body) do
    %OpenFeature.Context{body: body}
  end

  def new_targeted_context(key, body) do
    %OpenFeature.Context{key: key, body: body}
  end
end
