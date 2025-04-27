defmodule TaskCli do
  @data_file "private/tasks.db"
  @help_message """
    Available commands:
    - help: Show this help message
    - exit: Shutdown the application
    - add <task>: Add a task with given name
    - remove <task_id>: Remove a task with given id
    - list: List all tasks
    - done <task_id>: Mark a task as completed
    - undo <task_id>: Mark a task as incomplete
    - save: Save current tasks to a file
    - purge!: Purge all tasks from the database
  """

  def start do
    clear_screen()
    IO.puts("Welcome to TaskCLI!")
    IO.puts("Enter 'help' to see a list of available commands.")

    load_list()
    |> load()
    |> setup()
    |> run()
  end

  defp load({:error, _err}) do
    IO.puts("Tasks database file not found, initializing empty list")

    case File.mkdir_p(Path.dirname(@data_file)) do
      :ok -> File.write(@data_file, "")
      {:error, err} -> exit("Could not create db file: #{err}")
    end

    []
  end

  defp load({:ok, ""}) do
    []
  end

  defp load({:ok, file_content}) do
    file_content
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, "\#{sep}\#") end)
  end

  defp load_list do
    File.read(@data_file)
  end

  defp save_list do
    result =
      Agent.get(:tasks, fn tasks ->
        file_data =
          tasks
          |> Enum.map(fn task -> Enum.join(task, "\#{sep}\#") end)
          |> Enum.join("\n")
          |> IO.inspect()

        File.write(@data_file, file_data)
      end)

    case result do
      :ok -> {:ok, "Tasks saved successfully"}
      {:error, err} -> {:error, err}
    end
  end

  defp setup(tasks) do
    Agent.start_link(fn -> tasks end, name: :tasks)

    Agent.start_link(
      fn ->
        Enum.map(1..9999, fn id ->
          String.pad_leading(Integer.to_string(id), 4, "0")
        end)
        |> Enum.reject(fn av_id -> Enum.any?(tasks, fn [id, _, _] -> av_id == id end) end)
      end,
      name: :available_ids
    )
  end

  defp clear_screen do
    IO.write(IO.ANSI.clear())
    IO.write(IO.ANSI.cursor(0, 0))
  end

  defp run({:ok, pid}) do
    IO.write("Command: > ")

    IO.read(:stdio, :line)
    |> String.trim()
    |> handle_input()

    run({:ok, pid})
  end

  defp run({:error, err}) do
    exit("Could not properly setup state #{err}")
  end

  defp print_list_header do
    IO.write(String.pad_leading("ID", 4, " "))
    IO.write(" | ")
    IO.write(String.pad_leading("Task name", 20, " "))
    IO.write(" | ")
    IO.write(String.pad_leading("Completed at:", 10, " ") <> "\n")
  end

  defp handle_input("exit") do
    Agent.stop(:tasks)
    IO.puts("Bye... Exiting")
    :timer.sleep(1000)
    clear_screen()
    exit(:normal)
  end

  defp handle_input("help") do
    clear_screen()
    IO.puts(@help_message)
  end

  defp handle_input("add") do
    IO.puts("Please provide a task name")
  end

  defp handle_input("add " <> task) do
    new_task =
      [
        Agent.get_and_update(:available_ids, fn [id | available_ids] ->
          {id, available_ids}
        end),
        String.trim(task),
        ""
      ]

    Agent.update(:tasks, fn tasks -> [new_task | tasks] end)
  end

  defp handle_input("remove") do
    IO.puts("Please provide a task id")
  end

  defp handle_input("remove " <> task_id) do
    Agent.update(:tasks, fn tasks ->
      Enum.reject(tasks, fn [id, _, _] -> id == String.pad_leading(task_id, 4, "0") end)
    end)

    Agent.update(:available_ids, fn ids -> [String.pad_leading(task_id, 4, "0") | ids] end)
    clear_screen()
    IO.puts("Task with id: #{task_id} removed")
  end

  defp handle_input("done") do
    IO.puts("Please provide a task id")
  end

  defp handle_input("done " <> task_id) do
    Agent.update(:tasks, fn tasks ->
      Enum.map(tasks, fn [id, name, status] ->
        if id == String.pad_leading(task_id, 4, "0") do
          [id, name, DateTime.utc_now() |> DateTime.to_string()]
        else
          [id, name, status]
        end
      end)
    end)
  end

  defp handle_input("undone") do
    IO.puts("Please provide a task id")
  end

  defp handle_input("undone " <> task_id) do
    Agent.update(:tasks, fn tasks ->
      Enum.map(tasks, fn [id, name, status] ->
        if id == String.pad_leading(task_id, 4, "0") do
          [id, name, ""]
        else
          [id, name, status]
        end
      end)
    end)
  end

  defp handle_input("list") do
    clear_screen()
    print_list_header()

    Enum.each(Agent.get(:tasks, fn tasks -> tasks end), fn [id, name, status] ->
      IO.write(String.pad_leading(id, 4, "0"))
      IO.write(" | ")
      IO.write(String.pad_leading(name, 20, " "))
      IO.write(" | ")

      case status do
        "" -> IO.write("Incomplete\n")
        _ -> IO.write(String.pad_leading(status, 10, " ") <> "\n")
      end
    end)
  end

  defp handle_input("save") do
    clear_screen()

    case save_list() do
      {:ok, msg} -> IO.puts("Success: " <> msg)
      {:error, err} -> IO.puts("Error while saving to file: " <> err)
    end
  end

  defp handle_input("purge!") do
    Agent.update(:tasks, fn _ -> [] end)
    save_list()
    clear_screen()
    IO.puts("Tasks purged")
  end

  defp handle_input("") do
    clear_screen()
  end

  defp handle_input(input) do
    clear_screen()
    IO.puts("Unrecognized input: #{input}")
  end
end
