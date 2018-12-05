Code.load_file("time_frame.exs", "..")

defmodule Polymer do
  def remove_opposites(units, ignore_units \\ '') do
    Enum.reduce(units, '', fn char, acc ->
      if char in ignore_units do
        acc
      else
        drop_opposite(acc, char)
      end
    end)
    |> Enum.reverse()
  end

  defp drop_opposite([previous | tail] = accumulator, current) do
    if current != previous and abs(previous - current) == 32 do
      tail
    else
      [current | accumulator]
    end
  end

  defp drop_opposite(_, current), do: [current]
end

defmodule SolutionPartOne do
  def solve(input) do
    input
    |> String.to_charlist()
    |> Polymer.remove_opposites()
    |> Enum.count()
  end
end

defmodule SolutionPartTwo do
  def solve(input) do
    input_list =
      input
      |> String.to_charlist()

    ?A..?Z
    |> Enum.reduce(-1, fn unwanted_unit, min ->
      polymer_length =
        input_list
        |> Polymer.remove_opposites([unwanted_unit] ++ [unwanted_unit + 32])
        |> Enum.count()

      if polymer_length < min or min < 0,
        do: polymer_length,
        else: min
    end)
  end
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne
  alias SolutionPartTwo, as: PartTwo

  test "Part I" do
    assert PartOne.solve("aA") == 0
    assert PartOne.solve("Aa") == 0
    assert PartOne.solve("abBA") == 0
    assert PartOne.solve("abAB") == 4
    assert PartOne.solve("aabAAB") == 6
    assert PartOne.solve("dabAcCaCBAcCcaDA") == 10
  end

  test "Part II" do
    assert PartTwo.solve("dabAcCaCBAcCcaDA") == 4
  end
end

defmodule Day do
  require TimeFrame

  def run do
    input =
      "input.txt"
      |> File.read!()

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
