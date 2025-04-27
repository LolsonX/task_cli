defmodule TaskCli.UI do
  def clear_screen do
    IO.write(IO.ANSI.clear())
    IO.write(IO.ANSI.cursor(0, 0))
  end

  def print_task_list(tasks) do
    IO.puts(
      String.pad_leading("ID", 4) <> " | " <> String.pad_trailing("Task", 20) <> " | Completed At"
    )

    IO.puts(String.duplicate("-", 50))

    Enum.each(tasks, fn [id, name, completed_at] ->
      case completed_at do
        "" -> IO.write(IO.ANSI.red())
        _ -> IO.write(IO.ANSI.green())
      end

      IO.puts("#{id} | #{String.pad_trailing(name, 20)} | #{format_status(completed_at)}")
    end)

    IO.write(IO.ANSI.reset())
  end

  def render_prompt do
    IO.write(IO.ANSI.reverse() <> "Command|>" <> IO.ANSI.reverse_off() <> " ")
  end

  defp format_status(""), do: "Incomplete"
  defp format_status(datetime), do: datetime
end
