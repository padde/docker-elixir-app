defmodule App.Repo.Migrations.CreateTodoItems do
  use Ecto.Migration

  def change do
    create table(:todo_items) do
      add :body, :text

      timestamps()
    end

  end
end
