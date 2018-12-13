Code.load_file("time_frame.exs", "..")

defmodule Plant do
  def spread([l1, l2, c, r1, r2 | tail], notes, generation, last_generation, acc) do
    result = Map.get(notes, "#{l1}#{l2}#{c}#{r1}#{r2}", ".")
    spread([l2, c, r1, r2 | tail], notes, generation, last_generation, [result | acc])
  end

  def spread(pots, notes, generation, last_generation, acc) do
    result = Map.get(notes, to_string(pots), ".")

    # IO.puts("Gen #{generation} " <> to_string(~w(. .) ++ Enum.reverse([result | acc]) ++ ~w(. .)))

    if generation < last_generation do
      spread(
        ~w(. .) ++ Enum.reverse([result | acc]) ++ ~w(. .),
        notes,
        generation + 1,
        last_generation,
        []
      )
    else
      Enum.reverse([result | acc])
    end
  end

  def count(pots) do
    {count, _} =
      Enum.reduce(pots, {0, -1}, fn pot, {sum, idx} ->
        if pot == "#" do
          {sum + idx, idx + 1}
        else
          {sum, idx + 1}
        end
      end)

    count
  end
end

defmodule SolutionPartOne do
  def solve(initial_state, notes) do
    initial_state = ~w(. . .) ++ initial_state
    initial_state = initial_state ++ ~w(. . .)

    initial_state
    |> Plant.spread(notes, 1, 20, [])
    |> Plant.count()
  end
end

defmodule SolutionPartTwo do
  def solve(initial_state, notes) do
    initial_state = ~w(. . .) ++ initial_state
    initial_state = initial_state ++ ~w(. . .)

    Stream.cycle(100..100)
    |> Enum.reduce_while({0, 0, initial_state}, fn limit, {count, prev_limit, state} ->
      current_state =
        initial_state
        |> Plant.spread(notes, 1, prev_limit + limit, [])

      current_count = Plant.count(current_state)
      IO.puts(current_count)

      if current_count != count do
        {:cont, {current_count, prev_limit + limit, current_state}}
      else
        {:halt, {current_count, prev_limit, current_state}}
      end
    end)
  end
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
      |> SolutionPartTwo.solve(notes)
      |> IO.puts()
    end
  end
end

Day.run()
