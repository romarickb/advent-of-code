Code.load_file("time_frame.exs", "..")

defmodule Worker do
  def create_workers(count) do
    1..count
    |> Enum.map(fn id ->
      {id, :free, 0, 0}
    end)
  end

  def free_workers(workers) do
    workers =
      workers
      |> Enum.filter(fn {_, status, _, _} ->
        status == :free
      end)

    {length(workers), workers}
  end
end

defmodule Graph do
  def build(input) do
    input
    |> Enum.reduce(%{}, fn line, acc ->
      %{
        "step" => step,
        "req" => req
      } =
        Regex.named_captures(
          ~r/Step (?<req>.+) must be finished before step (?<step>.+) can begin./,
          line
        )

      acc =
        Map.update(acc, step, {:unprocessed, [req], [], 0}, fn {_, reqs, nexts, start_time} ->
          {:unprocessed, [req | reqs], nexts, start_time}
        end)

      Map.update(acc, req, {:unprocessed, [], [step], 0}, fn {state, reqs, nexts, start_time} ->
        {state, reqs, [step | nexts], start_time}
      end)
    end)
  end

  def available_steps(steps, graph) do
    steps
    |> Enum.filter(fn step -> available?(step, graph) end)
    |> Enum.sort()
  end

  defp available?(step, graph) do
    {status, reqs, _, _} = Map.get(graph, step)

    status == :unprocessed and
      Enum.reduce_while(reqs, true, fn step, acc ->
        {status, _, _, _} = Map.get(graph, step)
        if status == :processed, do: {:cont, acc}, else: {:halt, false}
      end) == true
  end
end

defmodule SolutionPartOne do
  def solve(input) do
    graph = input |> Graph.build()

    {_, result} =
      graph
      |> Map.keys()
      |> process({graph, []})

    result |> Enum.reverse() |> to_string()
  end

  defp process([], acc), do: acc

  defp process(steps, {graph, result}) do
    available_steps = Graph.available_steps(steps, graph)
    process_availables(available_steps, {graph, result})
  end

  defp process_availables([], acc), do: acc

  defp process_availables([step | tail], {graph, result}) do
    {_, reqs, nexts, start_time} = Map.get(graph, step)
    graph = Map.put(graph, step, {:processed, reqs, nexts, start_time})
    process(tail ++ nexts, {graph, [step | result]})
  end
end

defmodule SolutionPartTwo do
  def solve(input, workers_count) do
    graph =
      input
      |> Graph.build()

    process(workers_count, 0, Map.keys(graph), graph)
  end

  defp process(workers, time, steps, graph) do
    if(all_processed?(graph)) do
      time - 1
    else
      {workers, graph} = update_processed_steps(graph, workers, time)
      available_steps = Graph.available_steps(steps, graph) |> Enum.take(workers)
      {workers, graph} = process_availables(available_steps, workers, time, graph)
      process(workers, time + 1, steps -- available_steps, graph)
    end
  end

  defp all_processed?(graph) do
    Enum.reduce_while(graph, true, fn {_, {status, _, _, _}}, acc ->
      if status == :processed, do: {:cont, acc}, else: {:halt, false}
    end)
  end

  defp update_processed_steps(graph, workers, elapsed_time) do
    graph
    |> Enum.reduce({workers, graph}, fn {step, header}, {workers, graph} ->
      {status, reqs, nexts, start_time} = header

      if status == :pending and elapsed_time - start_time == time_to_process(step) do
        {workers + 1, Map.put(graph, step, {:processed, reqs, nexts, start_time})}
      else
        {workers, graph}
      end
    end)
  end

  defp process_availables([], workers, _, graph) when workers < 0, do: {0, graph}
  defp process_availables([], workers, _, graph), do: {workers, graph}

  defp process_availables([step | tail], workers, start_time, graph) do
    {_, reqs, nexts, _} = Map.get(graph, step)
    graph = Map.put(graph, step, {:pending, reqs, nexts, start_time})
    process_availables(tail, workers - 1, start_time, graph)
  end

  defp time_to_process(step) do
    <<v::utf8>> = step
    v - 64 + 60
  end
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne
  alias SolutionPartTwo, as: PartTwo

  test "Part I" do
    {:ok, io} =
      StringIO.open("""
      Step C must be finished before step A can begin.
      Step C must be finished before step F can begin.
      Step A must be finished before step B can begin.
      Step A must be finished before step D can begin.
      Step B must be finished before step E can begin.
      Step D must be finished before step E can begin.
      Step F must be finished before step E can begin.
      """)

    assert PartOne.solve(IO.stream(io, :line)) == "CABDFE"
  end

  test "Part II" do
    {:ok, io} =
      StringIO.open("""
      Step C must be finished before step A can begin.
      Step C must be finished before step F can begin.
      Step A must be finished before step B can begin.
      Step A must be finished before step D can begin.
      Step B must be finished before step E can begin.
      Step D must be finished before step E can begin.
      Step F must be finished before step E can begin.
      """)

    assert PartTwo.solve(IO.stream(io, :line), 2) == 258
  end
end

defmodule Day do
  require TimeFrame

  def run do
    input =
      "input.txt"
      |> File.stream!([], :line)

    IO.puts("Part I")

    TimeFrame.execute "Part I", :milliseconds do
      input
      |> SolutionPartOne.solve()
      |> IO.puts()
    end

    IO.puts("\nPart II")

    TimeFrame.execute "Part II", :milliseconds do
      input
      |> SolutionPartTwo.solve(5)
      |> IO.puts()
    end
  end
end

Day.run()
