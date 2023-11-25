defmodule OpenfeatureElixir.Config do
  defstruct [:name, :metadata, :clients]

  @type t :: %__MODULE__{
          name: String.t(),
          metadata: %{String.t() => String.t()},
          clients: %{String.t() => {module(), [any()]} | nil}
        }
end
