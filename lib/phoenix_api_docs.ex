defmodule PhoenixApiDocs do
  defmacro __using__(_) do
    quote do
      @on_definition unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :phoenix_api_docs, accumulate: true, persist: true)
    end
  end

  def __before_compile__(env) do
    Module.register_attribute(env.module, :phoenix_api_controller_docs, persist: true)

    case Module.get_attribute(env.module, :api_controller_doc) do
      doc when is_binary(doc) ->
        keyword = [doc: doc, title: inspect(env.module)]
        Module.put_attribute(env.module, :phoenix_api_controller_docs, format_keyword(keyword))

      keyword when is_list(keyword) ->
        keyword = Keyword.put_new(keyword, :title, inspect(env.module))
        Module.put_attribute(env.module, :phoenix_api_controller_docs, format_keyword(keyword))

      nil ->
        if Module.get_attribute(env.module, :phoenix_api_docs) == [] do
          Module.delete_attribute(env.module, :phoenix_api_docs)
        end
        :ok
    end
  end

  def __on_definition__(env, _kind, name, _args, _guards, _body) do
    case Module.get_attribute(env.module, :api_doc) do
      doc when is_binary(doc) ->
        Module.put_attribute(env.module, :phoenix_api_docs, {name, format_keyword(doc: doc)})
        Module.delete_attribute(env.module, :api_doc)

      keyword when is_list(keyword) ->
        Module.put_attribute(env.module, :phoenix_api_docs, {name, format_keyword(keyword)})
        Module.delete_attribute(env.module, :api_doc)

      nil ->
        :ok
    end
  end

  defp format_keyword(keyword) do
    %{
      title: Keyword.get(keyword, :title, nil),
      doc: Keyword.fetch!(keyword, :doc)
    }
  end
end
