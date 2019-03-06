defmodule Ecto.ReleaseTasks.Help do
  @shortdoc """
  Show this help message
  """

  @moduledoc """
  Show help for ecto release tasks.

  EXAMPLES

    ecto help
    ecto help create
  """

  use Ecto.ReleaseTasks.Task

  @message """
  USAGE
    <%= rel_name %> ecto <task> [options] [args...]

  COMMANDS

  <%= for command <- commands do %>
    <%= String.pad_trailing(command.name, max_len) %> <%= command.shortdoc %>
  <% end %>
  """

  @doc false
  def run([task]) do
    com = Enum.find commands(), &(&1.name == task)
    if com do
      IO.write(com.moduledoc)
    else
      IO.puts("the task 'ecto #{task}' does not exist")
      run []
    end
  end

  def run(_) do
    @message
    |> EEx.eval_string([
      rel_name: System.get_env("REL_NAME"),
      commands: commands(),
      max_len: max_command_len(),
    ], [trim: true])
    |> IO.write()
  end

  defp commands() do
    for {name, module} <- Ecto.ReleaseTasks.commands() do
      %{
        name: to_string(name),
        module: module,
        shortdoc: module.__doc__().shortdoc,
        moduledoc: module.__doc__().moduledoc
      }
    end
  end

  defp max_command_len() do
    commands()
    |> Enum.map(fn com -> String.length(com.name) end)
    |> Enum.max()
  end
end
