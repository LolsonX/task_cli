defmodule TaskCli.Notifier do
  def notify(message) do
    IO.write(:stderr, ANSIExt.store_cursor())

    case message do
      "" ->
        Enum.each(30..36, fn line -> IO.write(IO.ANSI.cursor(line, 0) <> IO.ANSI.clear_line()) end)

      _ ->
        IO.write(:stderr, IO.ANSI.cursor(30, 0) <> "Unfinished tasks:\n#{message}")
    end

    IO.write(:stderr, ANSIExt.restore_cursor())
  end
end
