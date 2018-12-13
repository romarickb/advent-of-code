Code.load_file("time_frame.exs", "..")

defmodule Track do
  def build(input) do
    input
    |> Enum.reduce({{0, 0}, %{}, []}, fn line, {{x, y}, track, players} ->
      IO.puts(line)

      {{x, y}, track, players} =
        line
        |> String.to_charlist()
        |> IO.inspect()
        |> Enum.reduce({{x, y}, track, players}, fn char, {{x, y}, track, players} ->
          case char do
            '-' ->
              {{x + 1, y}, Map.put(track, {x, y}, :straight), players}

            '|' ->
              {{x + 1, y}, Map.put(track, {x, y}, :straight), players}

            '\\' ->
              {{x + 1, y}, Map.put(track, {x, y}, :right), players}

            '/' ->
              {{x + 1, y}, Map.put(track, {x, y}, :left), players}

            '<' ->
              {{x + 1, y}, track, [{x, y, :left, :intersec_left} | players]}

            '+' ->
              {{x + 1, y}, Map.put(track, {x, y}, :intersection), players}

            '\n' ->
              {{0, y + 1}, track, players}

            other ->
              IO.puts(to_string(other))
              {{x, y}, track, players}
          end
        end)

      {{0, y + 1}, track, players}
    end)
    |> IO.inspect()
  end
end

defmodule SolutionPartOne do
  def solve(input) do
    Track.build(input)
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
    {:ok, io} =
      StringIO.open("""
      /->-\
      |   |  /----\
      | /-+--+-\  |
      | | |  | v  |
      \-+-/  \-+--/
      \------/
      """)

    assert PartOne.solve(IO.stream(io, :line)) == {7, 3}
  end

  test "Part II" do
    assert PartTwo.solve('test') == 'test'
  end
end

defmodule Day do
  require TimeFrame

  def run do
    input = "foobar"

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
