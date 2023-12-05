defmodule OpenFeature.Provider do
  # TODO: add child_spec stuff
  # @callback child_spec() :: Supervisor.child_spec()

  @callback get_boolean_value(
              tag :: term,
              name :: term,
              default :: boolean(),
              context :: %OpenFeature.Context{}
            ) :: boolean()

  @callback get_string_value(
              tag :: term,
              name :: term,
              default :: binary(),
              context :: %OpenFeature.Context{}
            ) :: binary()

  @callback get_number_value(
              tag :: term,
              name :: term,
              default :: number(),
              context :: %OpenFeature.Context{}
            ) :: number()

  # @optional_callbacks child_spec: 0
end
