defmodule Parser.Schema.Markdown do
  use Parser.Schema

  embedded_schema do
    field :content, :string
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [:content])
    |> validate_required([:content])
    |> validate_parser(:content)
  end

  defp validate_parser(changeset, field) do
    validate_change(changeset, field, fn _, content ->
      case Earmark.as_html(content, compact_output: true) do
        {:ok, _html, _} -> []
        _ -> [{field, "Markdown has invalid format"}]
      end
    end)
  end
end
