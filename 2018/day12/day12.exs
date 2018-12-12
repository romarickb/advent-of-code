Code.load_file("time_frame.exs", "..")

defmodule SolutionPartOne do
  def solve(initial_state, notes) do
    intial_state = ~w(. . . .) ++ initial_state
    initial_state = initial_state ++ ~w(. . . .)

    initial_state
    |> spread(notes, 1, [])
    |> to_string()
  end

  defp spread(pots, _, generation, acc) when generation == 20, do: acc |> IO.inspect()

  defp spread([], notes, generation, acc), do: spread(acc, notes, generation + 1, [])

  defp spread([l1, l2, c, r1, r2 | tail], notes, generation, acc) do
    IO.puts("Generation #{generation}")
    result = Map.get(notes, "#{l1}#{l2}#{c}#{r1}#{r2}", ".")
    spread([l2, c, r1, r2 | tail], notes, generation, [result | acc])
  end

  defp spread(pots, notes, generation, acc) do
    acc |> IO.inspect()
    spread(acc, notes, generation + 1, [])
  end

  defp count_plants() do
    10
  end
end

defmodule SolutionPartTwo do
  def solve(input), do: input
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne
  alias SolutionPartTwo, as: PartTwo

  test "Part I" do
    initial_state = "#..#.#..##......###...###" |> String.graphemes()

    notes = %{
      "...##" => "#",
      "..#.." => "#",
      ".#..." => "#",
      ".#.#." => "#",
      ".#.##" => "#",
      ".##.." => "#",
      ".####" => "#",
      "#.#.#" => "#",
      "#.###" => "#",
      "##.#." => "#",
      "##.##" => "#",
      "###.." => "#",
      "###.#" => "#",
      "####." => "#"
    }

    assert PartOne.solve(initial_state, notes) == 325
  end

  test "Part II" do
    assert PartTwo.solve('test') == 'test'
  end
end

defmodule Day do
  require TimeFrame

  def run do
    initial_state =
      "##.#############........##.##.####..#.#..#.##...###.##......#.#..#####....##..#####..#.#.##.#.##"
      |> String.graphemes()

    notes = %{
      "###.#" => "#",
      ".####" => "#",
      "#.###" => ".",
      ".##.." => ".",
      "##..." => "#",
      "##.##" => "#",
      ".#.##" => "#",
      "#.#.." => "#",
      "#...#" => ".",
      "...##" => "#",
      "####." => "#",
      "#..##" => ".",
      "#...." => ".",
      ".###." => ".",
      "..#.#" => ".",
      "..###" => ".",
      "#.#.#" => "#",
      "....." => ".",
      "..##." => ".",
      "##.#." => "#",
      ".#..." => "#",
      "#####" => ".",
      "###.." => "#",
      "..#.." => ".",
      "##..#" => "#",
      "#..#." => "#",
      "#.##." => ".",
      "....#" => ".",
      ".#..#" => "#",
      ".#.#." => "#",
      ".##.#" => ".",
      "...#." => "."
    }

    IO.puts("Part I")

    TimeFrame.execute "Part I", :milliseconds do
      initial_state
      |> SolutionPartOne.solve(notes)
      |> IO.puts()
    end

    IO.puts("\nPart II")

    TimeFrame.execute "Part II", :milliseconds do
      initial_state
      |> SolutionPartTwo.solve()
      |> IO.puts()
    end
  end
end

# Day.run()
