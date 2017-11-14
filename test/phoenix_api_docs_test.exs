defmodule PhoenixApiDocsTest do
  use ExUnit.Case
  doctest PhoenixApiDocs

  test "greets the world" do
    assert PhoenixApiDocs.hello() == :world
  end
end
