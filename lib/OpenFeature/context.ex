defmodule OpenFeature.Context do
  @moduledoc """
  A struct that represents the context of a feature flag evaluation.
  """
  defstruct [:body, key: ""]

  def new_targetless_context(body) do
    %OpenFeature.Context{body: body}
  end

  def new_targeted_context(key, body) do
    %OpenFeature.Context{key: key, body: body}
  end

  def rollup_context(%OpenFeature.Config{global_context: nil, local_context: nil}) do
    OpenFeature.Context.new_targetless_context(%{})
  end

  def rollup_context(%OpenFeature.Config{global_context: nil, local_context: _}) do
    OpenFeature.Context.new_targetless_context(%{})
  end

  def rollup_context(%OpenFeature.Config{global_context: _, local_context: nil}) do
    OpenFeature.Context.new_targetless_context(%{})
  end

  def rollup_context(nil, nil) do
    OpenFeature.Context.new_targetless_context(%{})
  end

  def rollup_context(nil, second) do
    second
  end

  def rollup_context(first, nil) do
    first
  end

  def rollup_context(%OpenFeature.Context{} = first, %OpenFeature.Context{} = second) do
    if is_nil(first.key) && is_nil(second.key) do
      OpenFeature.Context.new_targetless_context(Map.merge(first.body, second.body))
    else
      OpenFeature.Context.new_targeted_context(
        first.key || second.key,
        Map.merge(first.body, second.body)
      )
    end
  end

  def rollup_context(first, nil, nil) do
    first
  end

  def rollup_context(nil, second, nil) do
    second
  end

  def rollup_context(nil, nil, third) do
    third
  end

  def rollup_context(first, second, nil) do
    rollup_context(first, second)
  end

  def rollup_context(first, nil, third) do
    rollup_context(first, third)
  end

  def rollup_context(nil, second, third) do
    rollup_context(second, third)
  end

  def rollup_context(
        %OpenFeature.Context{} = first,
        %OpenFeature.Context{} = second,
        %OpenFeature.Context{} = third
      ) do
    rollup_context(first, second) |> rollup_context(third)
  end
end
