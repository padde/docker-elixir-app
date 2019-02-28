defmodule App.Repo do
  use Ecto.Repo,
    otp_app: :app,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    if config[:load_from_system_env] do
      {:ok, Keyword.put(config, :url, get_env!("DATABASE_URI"))}
    else
      {:ok, config}
    end
  end

  defp get_env!(name) do
    System.get_env(name) || raise "expected the #{name} environment variable to be set"
  end
end
