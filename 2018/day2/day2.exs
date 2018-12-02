Code.load_file("time_frame.exs", "..")

defmodule SolutionPartOne do
  def solve(input) do
    {doubles, triples} = do_solve(input)
    doubles * triples
  end

  defp do_solve([]), do: {0, 0}
  defp do_solve([id]), do: double_triple(id)

  defp do_solve(ids) do
    half_size = div(Enum.count(ids), 2)
    {ids_a, ids_b} = Enum.split(ids, half_size)
    merge(do_solve(ids_a), do_solve(ids_b))
  end

  defp double_triple(id) do
    id
    |> String.graphemes()
    |> Enum.sort()
    |> Enum.chunk_by(fn letter -> letter end)
    |> Enum.sort(&(length(&1) >= length(&2)))
    |> Enum.reduce({0, 0}, fn arg, {double, triple} ->
      case length(arg) do
        2 ->
          {1, triple}

        3 ->
          {double, 1}

        _ ->
          {double, triple}
      end
    end)
  end

  defp merge({double_count_a, triple_count_a}, {double_count_b, triple_count_b}) do
    {double_count_a + double_count_b, triple_count_a + triple_count_b}
  end
end

defmodule SolutionPartTwo do
  def solve(input) do
    input
    |> Enum.map(&String.graphemes(&1))
    |> Enum.sort()
    |> Enum.reduce_while([], &reduce_common_letters/2)
  end

  defp reduce_common_letters(current, previous) do
    {count, common_chars} = common_parts(current, previous, {0, []})

    if length(current) - count == 1 do
      {:halt, common_chars |> List.to_string()}
    else
      {:cont, current}
    end
  end

  defp common_parts([], _, {count, common_chars}), do: {count, Enum.reverse(common_chars)}
  defp common_parts(_, [], {count, common_chars}), do: {count, Enum.reverse(common_chars)}

  defp common_parts([a | t_a], [b | t_b], {count, common_chars}) when a == b,
    do: common_parts(t_a, t_b, {count + 1, [a | common_chars]})

  defp common_parts([_ | t_a], [_ | t_b], acc), do: common_parts(t_a, t_b, acc)
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne
  alias SolutionPartTwo, as: PartTwo

  test "Part I" do
    assert PartOne.solve(["abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"]) ==
             12
  end

  test "Part II" do
    assert PartTwo.solve(["abcde", "fghij", "klmno", "pqrst", "fguij", "axcye", "wvxyz"]) ==
             "fgij"
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
