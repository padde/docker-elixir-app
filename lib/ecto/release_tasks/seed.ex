defmodule Ecto.ReleaseTasks.Seed do
  # Based on distillery migration guide
  # https://github.com/bitwalker/distillery/blob/b945641ebbc17848378f4cd0f1c116ec78326ad4/docs/guides/running_migrations.md

  @shortdoc "Runs the seed script"

  @aliases []

  @switches [
    pool_size: :integer
  ]

  @moduledoc """
  Runs the seed script.

  EXAMPLES

      ecto seed

  OPTIONS

    -r, --repo  the repo to create
    --quiet     do not log output
  """

  use Ecto.ReleaseTasks.Task

  def run(args) do
    repos = parse_repo(args)
    {opts, _} = OptionParser.parse! args, strict: @switches, aliases: @aliases

    opts =
      if opts[:quiet],
        do: Keyword.merge(opts, [log: false, log_sql: false]),
        else: opts

    Enum.each repos, fn repo ->
      ensure_repo(repo)
      {:ok, pid, _apps} = ensure_started(repo, opts)

      seed_script = priv_path_for(repo, "seeds.exs")

      if File.exists?(seed_script) do
        IO.puts("Running seed script..")
        Code.eval_file(seed_script)
      end

      pid && repo.stop()
    end
  end
end
