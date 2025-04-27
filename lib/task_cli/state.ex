defmodule TaskCli.State do
  def setup(tasks) do
    Agent.start_link(fn -> tasks end, name: :tasks)
    Agent.start_link(fn -> generate_available_ids(tasks) end, name: :available_ids)
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
end
