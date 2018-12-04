Code.load_file("time_frame.exs", "..")

defmodule LogHelper do
  def sort(input) do
    input
    |> Stream.map(fn line ->
      Regex.named_captures(
        ~r/\[(?<date>.+)\] (?<description>.+)/,
        line
      )
      |> Enum.reduce([], fn {key, value}, acc ->
        IO.inspect({key, value})

        value =
          case key do
            "date" ->
              DateTime.from_naive(NaiveDateTime.new(value), "Etc/UTC")

            "description" ->
              value
          end

        Map.put(acc, key, value)
      end)
    end)
    |> Enum.map(fn item -> item end)
  end
end

defmodule SolutionPartOne do
  def solve(input) do
    input
    |> LogHelper.sort()
  end
end

defmodule SolutionPartTwo do
  def solve(input) do
    input
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
      [1518-11-01 00:00] Guard #10 begins shift
      [1518-11-01 23:58] Guard #99 begins shift
      [1518-11-01 00:05] falls asleep
      [1518-11-01 00:25] wakes up
      [1518-11-02 00:40] falls asleep
      [1518-11-04 00:02] Guard #99 begins shift
      [1518-11-03 00:24] falls asleep
      [1518-11-01 00:30] falls asleep
      [1518-11-01 00:55] wakes up
      [1518-11-04 00:46] wakes up
      [1518-11-05 00:45] falls asleep
      [1518-11-02 00:50] wakes up
      [1518-11-03 00:29] wakes up
      [1518-11-03 00:05] Guard #10 begins shift
      [1518-11-04 00:36] falls asleep
      [1518-11-05 00:55] wakes up
      [1518-11-05 00:03] Guard #99 begins shift
      """)

    assert PartOne.solve(IO.stream(io, :line)) == 4
  end

  test "Part II" do
    {:ok, io} =
      StringIO.open("""
      #1 @ 1,3: 4x4
      #2 @ 3,1: 4x4
      #3 @ 5,5: 2x2
      """)

    assert PartTwo.solve(IO.stream(io, :line)) == 3
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
      |> SolutionPartTwo.solve()
      |> IO.puts()
    end
  end
end

# Day.run()
