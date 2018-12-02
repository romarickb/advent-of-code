Code.load_file("time_frame.exs", "..")

defmodule SolutionPartOne do
  def solve(input) do
    input
    |> Stream.map(&String.to_integer/1)
    |> Enum.sum()
  end
end

defmodule SolutionPartTwo do
  def solve(input) do
    input
    |> Enum.map(&String.to_integer/1)
    |> do_solve(0, MapSet.new() |> MapSet.put(0))
  end

  defp do_solve(
         [frequency_change | remaining_changes],
         current_frequency,
         computed_frequencies
       ) do
    new_frequency = current_frequency + frequency_change

    if MapSet.member?(computed_frequencies, new_frequency),
      do: new_frequency,
      else:
        do_solve(
          remaining_changes ++ [frequency_change],
          new_frequency,
          MapSet.put(computed_frequencies, new_frequency)
        )
  end
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne
  alias SolutionPartTwo, as: PartTwo

  test "Part I" do
    assert PartOne.solve(["+1", "+1", "+1"]) == 3
    assert PartOne.solve(["+1", "+1", "-2"]) == 0
  end

  test "Part II" do
    assert PartTwo.solve(["+1", "-1"]) == 0
    assert PartTwo.solve(["+3", "+3", "+4", "-2", "-4"]) == 10
    assert PartTwo.solve(["-6", "+3", "+8", "+5", "-6"]) == 5
    assert PartTwo.solve(["+7", "+7", "-2", "-7", "-4"]) == 14
  end
end

defmodule Day do
  require TimeFrame

  def run do
    input =
      "input.txt"
      |> File.stream!()
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.to_list()

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

Day.run()
