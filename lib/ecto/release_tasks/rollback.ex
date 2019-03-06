defmodule Ecto.ReleaseTasks.Rollback do
  # Based on mix ecto.rollback
  # https://github.com/elixir-ecto/ecto_sql/blob/5e78291dbc8c0c6d249d8ad7150c120a4a836c59/lib/mix/tasks/ecto.rollback.ex

  @shortdoc "Rolls back the repository migrations"

  @aliases [
    r: :repo,
    n: :step
  ]

  @switches [
    all: :boolean,
    step: :integer,
    to: :integer,
    start: :boolean,
    quiet: :boolean,
    prefix: :string,
    pool_size: :integer,
    log_sql: :boolean,
    repo: [:keep, :string]
  ]

  @moduledoc """
  Reverts applied migrations in the given repository.

  This task runs all pending migrations by default. Runs the last
  applied migration by default. To roll back to a version number,
  supply `--to version_number`. To roll back a specific number of
  times, use `--step n`. To undo all applied migrations, provide
  `--all`.

  EXAMPLES

    ecto rollback
    ecto rollback -r Custom.Repo
    ecto rollback -n 3
    ecto rollback --step 3
    ecto rollback --to 20080906120000

  OPTIONS

    -r, --repo   the repo to rollback
    --all        revert all applied migrations
    --step -n    revert n number of applied migrations
    --to         revert all migrations down to and including version
    --quiet      do not log migration commands
    --prefix     the prefix to run migrations on
    --pool-size  the pool size if the repository is started only for the task
                 (defaults to 1)
    --log-sql    log the raw sql migrations are running
  """

  use Ecto.ReleaseTasks.Task

  def run(args, migrator \\ &Ecto.Migrator.run/4) do
    repos = parse_repo(args)
    {opts, _} = OptionParser.parse! args, strict: @switches, aliases: @aliases

    opts =
      if opts[:to] || opts[:step] || opts[:all],
        do: opts,
        else: Keyword.put(opts, :step, 1)

    opts =
      if opts[:quiet],
        do: Keyword.merge(opts, [log: false, log_sql: false]),
        else: opts

    Enum.each repos, fn repo ->
      ensure_repo(repo)
      path = ensure_migrations_path(repo)
      {:ok, pid, apps} = ensure_started(repo, opts)

      pool = repo.config[:pool]
      migrated =
        if function_exported?(pool, :unboxed_run, 2) do
          pool.unboxed_run(repo, fn -> migrator.(repo, path, :down, opts) end)
        else
          migrator.(repo, path, :down, opts)
        end

      pid && repo.stop()
      restart_apps_if_migrated(apps, migrated)
    end
  end
end
