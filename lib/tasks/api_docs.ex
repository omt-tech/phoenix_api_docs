defmodule Mix.Tasks.ApiDocs do
  use Mix.Task

  alias PhoenixApiDocs.View

  def run(args, base \\ app_base(otp_app())) do
    Mix.Task.run("compile", args)

    args
    |> Enum.at(0)
    |> router(base)
    |> generate()

    Mix.shell().info("Generated API docs.")
  end

  defp generate(router) do
    html = View.page(%{routes: router.__routes__(), router: router})
    File.mkdir_p!("api_docs")
    File.write!("api_docs/index.html", html)
  end

  defp router(nil, base) do
    if Mix.Project.umbrella?() do
      Mix.raise("umbrella applications require an explicit router to be given to phx.routes")
    end

    web_router = web_mod(base, "Router")
    old_router = app_mod(base, "Router")

    loaded(web_router) || loaded(old_router) ||
      Mix.raise("""
      no router found at #{inspect(web_router)} or #{inspect(old_router)}.
      An explicit router module may be given to phx.routes.
      """)
  end

  defp router(router_name, _base) do
    arg_router = Module.concat("Elixir", router_name)
    loaded(arg_router) || Mix.raise("the provided router, #{inspect(arg_router)}, does not exist")
  end

  defp otp_app() do
    Keyword.fetch!(Mix.Project.config(), :app)
  end

  defp app_base(app) do
    case Application.get_env(app, :namespace, app) do
      ^app -> app |> to_string |> Macro.camelize()
      mod -> mod |> inspect()
    end
  end

  defp loaded(module), do: Code.ensure_loaded?(module) && module

  defp app_mod(base, name), do: Module.concat([base, name])

  defp web_mod(base, name), do: Module.concat(["#{base}Web", name])
end
