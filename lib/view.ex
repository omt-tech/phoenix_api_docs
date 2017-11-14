defmodule PhoenixApiDocs.View do
  require EEx

  ## Helpers

  def has_docs?(module) do
    case fetch_attributes(module) do
      {:ok, attrs} ->
        Keyword.has_key?(attrs, :phoenix_api_docs) ||
          Keyword.has_key?(attrs, :phoenix_api_controller_docs)

      _ ->
        false
    end
  end

  def get_controller_docs(module) do
    with {:ok, attrs} <- fetch_attributes(module),
         {:ok, [docs | _]} <- Keyword.fetch(attrs, :phoenix_api_controller_docs) do
      docs
    else
      _ -> nil
    end
  end

  def get_action_docs(module, function) do
    with path when is_list(path) <- :code.which(module),
         {:ok, {^module, [attributes: attrs]}} <- :beam_lib.chunks(path, [:attributes]),
         {:ok, all_docs} <- Keyword.fetch(attrs, :phoenix_api_docs),
         {:ok, docs} <- Keyword.fetch(all_docs, function) do
      docs
    else
      _ -> nil
    end
  end

  def render_docs(docs) do
    Earmark.as_html!(docs)
  end

  defp fetch_attributes(module) do
    with path when is_list(path) <- :code.which(module),
         {:ok, {^module, [attributes: attrs]}} <- :beam_lib.chunks(path, [:attributes]) do
      {:ok, attrs}
    else
      _ -> :error
    end
  end

  ## Templates

  EEx.function_from_file(:def, :page, "lib/templates/page.html.eex", [:assigns])
end
