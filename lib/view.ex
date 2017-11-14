defmodule PhoenixApiDocs.View do
  require EEx

  ## Helpers

  def get_docs(module, function) do
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

  ## Templates

  EEx.function_from_file(:def, :page, "lib/templates/page.html.eex", [:assigns])
end
