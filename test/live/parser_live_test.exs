defmodule ParserWeb.Live.ParserLiveTest do
  use ParserWeb.ConnCase, async: true

  test "displays the main page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert render(view) =~ "Markdown"
    assert render(view) =~ "Preview"
  end

  test "converts markdown to html", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> form("#markdown-converter", %{
      "markdown" => %{
        "content" => """
        # My checks
        - [x] checked
        - [ ] unchecked
        """
      }
    })
    |> render_submit()

    path = assert_patch(view)
    assert path =~ ~r/preview/

    assert view |> has_element?("input[type=checkbox]")
    assert view |> has_element?("input[checked=checked]")
  end
end
