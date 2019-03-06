defmodule Ecto.ReleaseTasks.Create do
  # Based on mix ecto.create
  # https://github.com/elixir-ecto/ecto/blob/454bd594637c0b45ed9dc7bb66702863236620be/lib/mix/tasks/ecto.create.ex

  @shortdoc "Creates the repository storage"

  @switches [
    quiet: :boolean,
    repo: [:string, :keep]
  ]

  @aliases [
    r: :repo,
    q: :quiet
  ]

  @moduledoc """
  Create the storage for the given repository.

  EXAMPLES

    ecto create
    ecto create -r Custom.Repo

  OPTIONS

    -r, --repo  the repo to create
    --quiet     do not log output
  """

  use Ecto.ReleaseTasks.Task

  @doc false
  def run(args) do
    repos = parse_repo(args)
    {opts, _} = OptionParser.parse! args, strict: @switches, aliases: @aliases

    Enum.each repos, fn repo ->
      ensure_repo(repo)
      case repo.__adapter__.storage_up(repo.config) do
        :ok ->
          unless opts[:quiet] do
            IO.puts "The database for #{inspect repo} has been created"
          end
        {:error, :already_up} ->
          unless opts[:quiet] do
            IO.puts "The database for #{inspect repo} has already been created"
          end
        {:error, term} when is_binary(term) ->
          raise "The database for #{inspect repo} couldn't be created: #{term}"
        {:error, term} ->
          raise "The database for #{inspect repo} couldn't be created: #{inspect term}"
      end
    end
  end
end
