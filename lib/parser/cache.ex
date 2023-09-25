defmodule Parser.Cache do
  use Agent

  @spec start_link(any()) :: {:error, any} | {:ok, pid}
  def start_link(_) do
    Agent.start_link(fn -> %{markdown: "", ast: nil} end, name: __MODULE__)
  end

  @spec get(key :: atom()) :: String.t()
  def get(key) do
    Agent.get(__MODULE__, & &1)[key]
  end

  @spec update(key :: atom(), content :: String.t()) :: :ok
  def update(:markdown, content) when is_binary(content) do
    Agent.cast(__MODULE__, fn state -> %{state | markdown: content} end)
  end

  def update(:ast, content) when is_list(content) do
    Agent.cast(__MODULE__, fn state -> %{state | ast: content} end)
  end
end
