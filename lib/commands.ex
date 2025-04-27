defmodule TaskCli.Commands do
  alias TaskCli.{State, Storage, UI}

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

  def handle_input("exit") do
    State.update_tasks(fn _ -> [] end)
    IO.puts("Goodbye!")
    :timer.sleep(500)
    UI.clear_screen()
    exit(:normal)
  end

  def handle_input("help") do
    UI.clear_screen()
    IO.puts(@help_message)
  end

  def handle_input("list") do
    UI.clear_screen()
    UI.print_task_list(State.tasks())
  end

  def handle_input("save") do
    UI.clear_screen()

    case Storage.save_tasks(State.tasks()) do
      :ok -> IO.puts("Tasks saved successfully.")
      {:error, err} -> IO.puts("Failed to save: #{err}")
    end
  end

  def handle_input("purge!") do
    State.update_tasks(fn _ -> [] end)
    Storage.save_tasks([])
    UI.clear_screen()
    IO.puts("All tasks purged.")
  end

  def handle_input("add") do
    IO.puts("Please provide a task name.")
  end

  def handle_input("add " <> task_name) do
    id = State.pop_available_id()
    new_task = [id, String.trim(task_name), ""]
    State.update_tasks(fn tasks -> [new_task | tasks] end)
    IO.puts("Task added.")
  end

  def handle_input("remove") do
    IO.puts("Please provide a task ID.")
  end

  def handle_input("remove " <> id) do
    formatted_id = format_id(id)

    State.update_tasks(fn tasks ->
      Enum.reject(tasks, fn [task_id, _, _] -> task_id == formatted_id end)
    end)

    State.return_id(formatted_id)
    IO.puts("Task removed.")
  end

  def handle_input("done") do
    IO.puts("Please provide a task ID.")
  end

  def handle_input("done " <> id) do
    mark_task(id, DateTime.utc_now() |> DateTime.to_string())
  end

  def handle_input("undo") do
    IO.puts("Please provide a task ID.")
  end

  def handle_input("undo " <> id) do
    mark_task(id, "")
  end

  def handle_input("") do
    UI.clear_screen()
  end

  def handle_input(unknown) do
    UI.clear_screen()
    IO.puts("Unknown command: #{unknown}")
  end

  defp mark_task(id, status) do
    formatted_id = format_id(id)

    State.update_tasks(fn tasks ->
      Enum.map(tasks, fn
        [^formatted_id, name, _] -> [formatted_id, name, status]
        task -> task
      end)
    end)

    IO.puts("Task updated.")
  end

  defp format_id(id), do: String.pad_leading(id, 4, "0")
end
