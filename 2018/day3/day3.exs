Code.load_file("time_frame.exs", "..")

defmodule InputReader do
  def read(input) do
    input
    |> Stream.map(fn line ->
      Regex.named_captures(
        ~r/#(?<id>\d+) @ (?<left>\d+),(?<top>\d+): (?<wide>\d+)x(?<tall>\d+)/,
        line
      )
      |> Enum.reduce(
        %{},
        fn {k, v}, acc ->
          Map.put(acc, String.to_atom(k), String.to_integer(v))
        end
      )
    end)
  end
end

defmodule Occupations do
  def claims_per_square(input) do
    input
    |> Stream.flat_map(fn claim ->
      for x <- claim.left..(claim.left + claim.wide - 1),
          do:
            for(
              y <- claim.top..(claim.top + claim.tall - 1),
              do: %{claim_id: claim.id, square: {x, y}}
            )
    end)
    |> Stream.flat_map(fn claim -> claim end)
    |> Enum.reduce(%{}, fn %{claim_id: claim_id, square: square}, square_claims ->
      Map.update(square_claims, square, [claim_id], fn claim_ids -> [claim_id | claim_ids] end)
    end)
  end
end

defmodule SolutionPartOne do
  import InputReader
  import Occupations

  def solve(input) do
    input
    |> read()
    |> claims_per_square()
    |> Enum.reduce(0, fn {_, square_claims}, total_overlap ->
      if shared_square?(square_claims),
        do: total_overlap + 1,
        else: total_overlap
    end)
  end

  def shared_square?([]), do: false
  def shared_square?([_claim]), do: false
  def shared_square?(_), do: true
end

defmodule SolutionPartTwo do
  import InputReader
  import Occupations

  def solve(input) do
    input
    |> read()
    |> claims_per_square()
    |> Enum.reduce(%{loners: MapSet.new(), seen: MapSet.new()}, fn {_, area_ids}, acc ->
      update_loners(acc, area_ids)
    end)
    |> Map.get(:loners)
    |> Enum.fetch!(0)
  end

  defp update_loners(%{loners: loners, seen: seen} = state, [id]) do
    if MapSet.member?(seen, id),
      do: state,
      else: %{state | loners: MapSet.put(loners, id), seen: MapSet.put(seen, id)}
  end

  defp update_loners(state, ids) do
    ids
    |> Enum.reduce(state, fn id, acc ->
      %{loners: MapSet.delete(acc.loners, id), seen: MapSet.put(acc.seen, id)}
    end)
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
      #1 @ 1,3: 4x4
      #2 @ 3,1: 4x4
      #3 @ 5,5: 2x2
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

Day.run()
