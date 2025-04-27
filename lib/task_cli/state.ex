defmodule TaskCli.State do
  def setup(tasks) do
    Agent.start_link(fn -> tasks end, name: :tasks)
    Agent.start_link(fn -> generate_available_ids(tasks) end, name: :available_ids)
    Task.start_link(fn -> reminder_loop() end)
    Task.start_link(fn -> auto_save() end)
  end

  def tasks do
    Agent.get(:tasks, & &1)
  end

  def update_tasks(fun) do
    Agent.update(:tasks, fun)
  end

  def pop_available_id do
    Agent.get_and_update(:available_ids, fn [id | rest] -> {id, rest} end)
  end

  def return_id(id) do
    Agent.update(:available_ids, fn ids -> [id | ids] end)
  end

  def generate_available_ids(tasks) do
    1..9999
    |> Enum.map(fn id ->
      String.pad_leading(Integer.to_string(id), 4, "0")
    end)
    |> Enum.reject(fn av_id -> Enum.any?(tasks, fn [id, _, _] -> av_id == id end) end)
  end

  defp reminder_loop do
    Process.sleep(1000)

    Enum.reject(tasks(), fn [_, _, completed_at] -> completed_at != "" end)
    |> Enum.map(fn [id, name, _] -> "#{id}: #{name}" end)
    |> Enum.take(5)
    |> Enum.join("\n")
    |> notify()

    reminder_loop()
  end

  defp notify(message) do
    TaskCli.Notifier.notify(message)
  end

  defp auto_save do
    Process.sleep(1000 * 60)
    TaskCli.Storage.save_tasks(tasks())
    IO.write(:stderr, ANSIExt.store_cursor())
    IO.write(:stderr, IO.ANSI.cursor(29, 0) <> "Auto save completed" <> ANSIExt.restore_cursor())
    Process.sleep(500)

    IO.write(
      :stderr,
      ANSIExt.store_cursor() <>
        IO.ANSI.cursor(29, 0) <> IO.ANSI.clear_line() <> ANSIExt.restore_cursor()
    )

    auto_save()
  end
end
