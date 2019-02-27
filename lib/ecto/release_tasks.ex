defmodule Ecto.ReleaseTasks do
  # Based on
  #
  # * Ecto Task helpers
  #   https://github.com/elixir-ecto/ecto/blob/454bd594637c0b45ed9dc7bb66702863236620be/lib/mix/ecto.ex
  #
  # * EctoSQL Task helpers
  #   https://github.com/elixir-ecto/ecto_sql/blob/5e78291dbc8c0c6d249d8ad7150c120a4a836c59/lib/mix/ecto_sql.ex
  #
  # * Distillery Migrations Guide
  #   https://github.com/bitwalker/distillery/blob/b945641ebbc17848378f4cd0f1c116ec78326ad4/docs/guides/running_migrations.md

  @moduledoc false

  @otp_app :app

  @doc """
  Parses the repository option from the given command line args list.
  If no repo option is given, it is retrieved from the application environment.
  """
  @spec parse_repo([term]) :: [Ecto.Repo.t]
  def parse_repo(args) do
    parse_repo(args, [])
  end

  defp parse_repo([key, value|t], acc) when key in ~w(--repo -r) do
    parse_repo t, [Module.concat([value])|acc]
  end

  defp parse_repo([_|t], acc) do
    parse_repo t, acc
  end

  defp parse_repo([], []) do
    case Application.get_env(@otp_app, :ecto_repos, []) do
      [] ->
        raise "could not find Ecto repos"
        []
      repos ->
        repos
    end
  end

  defp parse_repo([], acc) do
    Enum.reverse(acc)
  end

  @doc """
  Ensures the given repository is started and running.
  """
  @spec ensure_started(Ecto.Repo.t, Keyword.t) :: {:ok, pid | nil, [atom]}
  def ensure_started(repo, opts) do
    {:ok, started} = Application.ensure_all_started(:ecto_sql)

    # If we starting EctoSQL just now, assume
    # logger has not been properly booted yet.
    if :ecto_sql in started && Process.whereis(Logger) do
      backends = Application.get_env(:logger, :backends, [])
      try do
        Logger.App.stop
        Application.put_env(:logger, :backends, [:console])
        :ok = Logger.App.start
      after
        Application.put_env(:logger, :backends, backends)
      end
    end

    {:ok, apps} = repo.__adapter__.ensure_all_started(repo.config(), :temporary)
    pool_size = Keyword.get(opts, :pool_size, 2)

    case repo.start_link(pool_size: pool_size) do
      {:ok, pid} ->
        {:ok, pid, apps}

      {:error, {:already_started, _pid}} ->
        {:ok, nil, apps}

      {:error, error} ->
        raise "Could not start repo #{inspect repo}, error: #{inspect error}"
    end
  end

  @doc """
  Returns the given repository's migrations path.
  """
  @spec ensure_migrations_path(Ecto.Repo.t) :: String.t
  def ensure_migrations_path(repo) do
    path = priv_path_for(repo, "migrations")
    if not File.dir?(path) do
      raise_missing_migrations(Path.relative_to_cwd(path), repo)
    end
    path
  end

  defp raise_missing_migrations(path, repo) do
    raise """
    Could not find migrations directory #{inspect path}
    for repo #{inspect repo}.
    This may be because you are in a new project and the
    migration directory has not been created yet. Creating an
    empty directory at the path above will fix this error.
    If you expected existing migrations to be found, please
    make sure your repository has been properly configured
    and the configured path exists.
    """
  end

  @doc """
  Restarts the app if there was any migration command.
  """
  @spec restart_apps_if_migrated([atom], list()) :: :ok
  def restart_apps_if_migrated(_apps, []), do: :ok
  def restart_apps_if_migrated(apps, [_|_]) do
    # Silence the logger to avoid application down messages.
    Logger.remove_backend(:console)
    for app <- Enum.reverse(apps) do
      Application.stop(app)
    end
    for app <- apps do
      Application.ensure_all_started(app)
    end
    :ok
  after
    Logger.add_backend(:console, flush: true)
  end

  @doc """
  Returns the private repository path for the given repo.
  """
  def priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    priv_dir = "#{:code.priv_dir(app)}"

    Path.join([priv_dir, repo_underscore, filename])
  end
end
