Mix.start()

Mix.shell(Mix.Shell.Process)

Code.require_file "../support/test_repo.exs", __DIR__

ExUnit.start()
