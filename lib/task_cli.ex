defmodule TaskCli do
  alias TaskCli.{Storage, State, Commands, UI}

  def start do
    UI.clear_screen()
    IO.puts("Welcome to TaskCLI! Type 'help' for commands.")

    Storage.load_tasks()
    |> State.setup()

    run()
  end

  defp run do
    UI.render_prompt()

    IO.read(:stdio, :line)
    |> String.trim()
    |> Commands.handle_input()

    run()
  end
end
