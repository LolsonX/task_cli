defmodule TaskCli.Storage do
  @data_file "private/tasks.db"
  @separator "\#{sep}\#"

  def load_tasks do
    case File.read(@data_file) do
      {:ok, ""} -> []
      {:ok, content} -> parse_tasks(content)
      {:error, _} -> init_db()
    end
  end

  def save_tasks(tasks) do
    file_content =
      tasks
      |> Enum.map(&Enum.join(&1, @separator))
      |> Enum.join("\n")

    File.write(@data_file, file_content)
  end

  defp parse_tasks(content) do
    content
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, @separator) end)
  end

  defp init_db do
    File.mkdir_p(Path.dirname(@data_file))
    File.write(@data_file, "")
    []
  end
end
