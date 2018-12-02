Code.load_file("time_frame.exs")

defmodule SolutionPartOne do
  def solve(input), do: input
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
    assert PartOne.solve('test') == 'test'
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

Day.run()
