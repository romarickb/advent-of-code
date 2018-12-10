Code.load_file("time_frame.exs", "..")

defmodule Circle do
  def new() do
    {[], [0]}
  end

  def add(marble, circle) do
    {pre, post} =
      circle
      |> next()
      |> next()

    {pre, [marble | post]}
  end

  def next({[], []} = circle), do: circle
  def next({pre, [current]}), do: {[], Enum.reverse([current | pre])}

  def next({pre, [current | post]}) do
    {[current | pre], post}
  end

  def pop(position, :counterclockwise, circle) do
    {removed_marble, circle} =
      1..position
      |> Enum.reduce(circle, fn _, acc -> prev(acc) end)
      |> pop_current()

    {removed_marble, circle}
  end

  defp prev({[], post}) do
    [current | pre] = Enum.reverse(post)
    {pre, [current]}
  end

  defp prev({[previous_value | pre], post}) do
    {pre, [previous_value | post]}
  end

  defp pop_current({pre, [current | post]}) do
    {current, {pre, post}}
  end
end

defmodule Game do
  def run(players, highest_marble) do
    {_, _, scores} =
      1..players
      |> Stream.cycle()
      |> Enum.reduce_while({0, Circle.new(), %{}}, fn player, acc ->
        {current_marble, circle, scores} = acc

        if(current_marble == highest_marble) do
          {:halt, acc}
        else
          {:cont, play(current_marble + 1, player, circle, scores)}
        end
      end)

    scores
  end

  defp play(marble, player, circle, scores) do
    if rem(marble, 23) == 0 do
      {removed_marble, circle} = Circle.pop(7, :counterclockwise, circle)

      turn_score = marble + removed_marble

      scores =
        Map.update(scores, player, turn_score, fn score ->
          score + turn_score
        end)

      {marble, circle, scores}
    else
      circle = Circle.add(marble, circle)

      {marble, circle, scores}
    end
  end

  def highest_score(scores) do
    {_, max_score} =
      scores
      |> Enum.max_by(fn {_, score} -> score end)

    max_score
  end
end

defmodule SolutionPartOne do
  def solve({players, highest_marble}) do
    scores = Game.run(players, highest_marble)

    Game.highest_score(scores)
  end
end

defmodule SolutionPartTwo do
  def solve({players, highest_marble}, multiplicator) do
    scores = Game.run(players, highest_marble * multiplicator)
    Game.highest_score(scores)
  end
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne

  test "Part I" do
    assert PartOne.solve({9, 25}) == 32
    assert PartOne.solve({10, 1618}) == 8317
    assert PartOne.solve({17, 1104}) == 2764
    assert PartOne.solve({21, 6111}) == 54718
    assert PartOne.solve({30, 5807}) == 37305
  end
end

defmodule Day do
  require TimeFrame

  def run do
    input = {413, 71082}

    IO.puts("Part I")

    TimeFrame.execute "Part I", :milliseconds do
      input
      |> SolutionPartOne.solve()
      |> IO.puts()
    end

    IO.puts("\nPart II")

    TimeFrame.execute "Part II", :milliseconds do
      input
      |> SolutionPartTwo.solve(100)
      |> IO.puts()
    end
  end
end

Day.run()
