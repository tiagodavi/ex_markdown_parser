defmodule ParserWeb.ParserLive do
  use ParserWeb, :live_view

  alias Parser.Cache
  alias Parser.Schema.Markdown

  @on_style "py-2 px-4 ml-4 text-blue-500 border-b-2 border-blue-500 focus:outline-none"
  @off_style "py-2 px-4 ml-4 text-gray-500 focus:outline-none"

  def mount(_params, _session, socket) do
    {:ok, start_socket(socket)}
  end

  def handle_params(_, _uri, %{assigns: %{live_action: :markdown}} = socket) do
    {:noreply, start_socket(socket)}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :preview}} = socket) do
    socket =
      assign(socket,
        markdown_style: @off_style,
        preview_style: @on_style,
        preview_content: preview(Cache.get(:ast))
      )

    {:noreply, socket}
  end

  def handle_event("check", %{"id" => id}, socket) do
    ast =
      Cache.get(:ast)
      |> Earmark.Transform.map_ast(&predicate(&1, id))

    Cache.update(:ast, ast)

    {:noreply, assign(socket, preview_content: preview(ast))}
  end

  def handle_event("validate", %{"markdown" => params}, socket) do
    form = build_form(params)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"markdown" => params}, socket) do
    form = build_form(params)
    content = build_content(form)

    if content.valid? do
      Cache.update(:markdown, content.markdown)
      Cache.update(:ast, content.ast)

      {:noreply, push_patch(socket, to: "/preview")}
    else
      {:noreply, assign(socket, form: form)}
    end
  end

  defp build_form(params) do
    %Markdown{}
    |> Markdown.changeset(params)
    |> Map.put(:action, :validate)
    |> to_form()
  end

  defp build_content(form) do
    if form.source.valid? do
      %{
        valid?: true,
        ast: build_ast(form.source.changes.content),
        markdown: form.source.changes.content,
        html: build_html(form.source.changes.content)
      }
    else
      %{
        valid?: false,
        ast: nil,
        markdown: "",
        html: ""
      }
    end
  end

  defp build_checkbox(content, acc) when is_binary(content) do
    capture = Regex.named_captures(~r/(?<data>(\[.*\]))/, content)

    if capture do
      content = Regex.replace(~r/\s*(\[.*\])\s*/, content, "")
      capture = Regex.replace(~r/(\[|\])/, capture["data"], "")
      capture = Regex.replace(~r/(\s)*/, String.downcase(capture), "")

      if capture == "x" do
        {{"label", [],
          [
            {"input",
             [
               {"type", "checkbox"},
               {"checked", "checked"},
               {"phx-click", "check"},
               {"phx-value-id", "ch-#{acc}"}
             ], [], %{}},
            content
          ], %{}}, acc + 1}
      else
        {{"label", [],
          [
            {"input",
             [
               {"type", "checkbox"},
               {"phx-click", "check"},
               {"phx-value-id", "ch-#{acc}"}
             ], [], %{}},
            content
          ], %{}}, acc + 1}
      end
    else
      {content, acc}
    end
  end

  defp build_checkbox(ast, acc), do: {ast, acc}

  defp build_html(content) do
    content
    |> build_ast()
    |> preview()
  end

  defp build_ast(content) do
    content
    |> Earmark.as_ast!()
    |> Earmark.Transform.map_ast_with(0, &build_checkbox/2)
    |> elem(0)
  end

  defp preview(ast) when not is_nil(ast) do
    Earmark.transform(ast, compact_output: true)
  end

  defp preview(_ast), do: ""

  defp predicate({"input", attrs, _, _} = node, target) do
    id = Earmark.AstTools.find_att_in_node(attrs, "phx-value-id")

    if id == target do
      checked? = Earmark.AstTools.find_att_in_node(attrs, "checked")

      if checked? do
        {"input", Enum.reject(attrs, &(&1 == {"checked", "checked"})), [], %{}}
      else
        {"input", [{"checked", "checked"} | attrs], [], %{}}
      end
    else
      node
    end
  end

  defp predicate(ast, _target), do: ast

  defp start_socket(socket) do
    form =
      %Markdown{}
      |> Markdown.changeset()
      |> to_form()

    assign(socket,
      markdown_style: @on_style,
      preview_style: @off_style,
      form: form
    )
  end
end
