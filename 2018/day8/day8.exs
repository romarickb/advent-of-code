Code.load_file("time_frame.exs", "..")

defmodule Tree do
  def build([], _, tree), do: {tree, []}

  def build([0, metadata_count | data], node_id, tree) do
    {metadatas, data} = data |> Enum.split(metadata_count)

    tree =
      Map.update(tree, node_id, {metadatas, []}, fn {_, child} ->
        {metadatas, []}
      end)

    {tree, data}
  end

  def build([child_count, metadata_count | data], node_id, tree) do
    {tree, data} =
      1..child_count
      |> Enum.reduce({tree, data}, fn child_id, {tree, data} ->
        child_id = node_id * 1000 + child_id

        tree =
          Map.update(tree, node_id, {[], [child_id]}, fn {metas, childs} ->
            {metas, [child_id | childs]}
          end)

        build(data, child_id, tree)
      end)

    {metadatas, data} = data |> Enum.split(metadata_count)

    tree =
      Map.update(tree, node_id, {metadatas, []}, fn {_, childs} ->
        {metadatas, childs}
      end)

    {tree, data}
  end
end

defmodule SolutionPartOne do
  def solve(input) do
    {tree, _} =
      input
      |> Tree.build(1, %{})

    tree
    |> Enum.reduce(0, fn {_, {metadatas, _}}, acc ->
      acc + Enum.sum(metadatas)
    end)
  end
end

defmodule SolutionPartTwo do
  def solve(input) do
    {tree, _} =
      input
      |> Tree.build(1, %{})

    node_value(tree, 1)
  end

  defp node_value(tree, node) do
    {metas, childs} = Map.get(tree, node)
    ordered_childs = Enum.reverse(childs)

    Enum.reduce(metas, 0, fn meta, acc ->
      child_id = Enum.at(ordered_childs, meta - 1)

      case Map.get(tree, child_id) do
        {metas, childs} ->
          if childs == [] do
            acc + Enum.sum(metas)
          else
            acc + node_value(tree, child_id)
          end

        _ ->
          acc
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
    assert PartOne.solve([2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]) == 138
  end

  test "Part II" do
    assert PartTwo.solve([2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]) == 66
  end
end

defmodule Day do
  require TimeFrame

  def run do
    input =
      "input.txt"
      |> File.read!()
      |> String.split(" ")
      |> Enum.map(fn n -> String.to_integer(n) end)

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
