defmodule App.Todo.TodoItem do
  use Ecto.Schema
  import Ecto.Changeset


  schema "todo_items" do
    field :body, :string

    timestamps()
  end

  @doc false
  def changeset(todo_item, attrs) do
    todo_item
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
