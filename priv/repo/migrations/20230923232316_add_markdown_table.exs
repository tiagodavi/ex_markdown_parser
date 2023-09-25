defmodule Parser.Repo.Migrations.AddMarkdownTable do
  use Ecto.Migration

  def change do
    create table("markdown") do
      add :content, :text

      timestamps()
    end
  end
end
