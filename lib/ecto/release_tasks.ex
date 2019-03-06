defmodule Ecto.ReleaseTasks do
  @otp_app :app

  @commands [
    create: Ecto.ReleaseTasks.Create,
    seed: Ecto.ReleaseTasks.Seed,
    migrate: Ecto.ReleaseTasks.Migrate,
    rollback: Ecto.ReleaseTasks.Rollback,
    help: Ecto.ReleaseTasks.Help
  ]

  for {cmd, module} <- @commands do
    def run([unquote(to_string(cmd)) | args]), do: unquote(module).run(args)
  end

  def run([]) do
    IO.puts "'ecto' needs one of the following commands"
    run ["help"]
    System.halt(1)
  end

  def run([cmd | _args]) do
    run ["help", cmd]
    System.halt(1)
  end

  def otp_app do
    @otp_app
  end

  def commands do
    @commands
  end
end
