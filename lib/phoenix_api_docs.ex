defmodule PhoenixApiDocs do
  defmacro __using__(_) do
    quote do
      @on_definition unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :phoenix_api_docs, accumulate: true, persist: true)
    end
  end

  def __on_definition__(env, kind, name, args, guards, body) do
    if value = Module.get_attribute(env.module, :api_doc) do
      Module.put_attribute(env.module, :phoenix_api_docs, {name, value})
      Module.delete_attribute(env.module, :api_doc)
    end
  end
end
