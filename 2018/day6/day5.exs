Code.load_file("time_frame.exs", "..")

defmodule SolutionPartOne do
  # {{1, 1}, %{{1,1} => 0, }
  def solve(input) do
    {min_x, max_x, min_y, max_y} = grid_edges(input)

    id_points =
      input
      |> identify()
      |> mark_points({min_x, max_x, min_y, max_y})

    Enum.reduce(min_x..max_x, %{}, fn x, acc ->
      Enum.reduce(min_y..max_y, acc, fn y, acc ->
        {id, _} =
          id_points
          |> Enum.reduce({-1, -1}, fn {id, point}, nearest_point ->
            {nearest_id, distance} = nearest_point
            IO.inspect(nearest_point)
            distance_from_point = manhattan_distance({x, y}, point)
            IO.inspect(distance_from_point)

            if distance_from_point < distance or distance == -1 do
              {id, distance_from_point}
            else
              if distance_from_point == distance do
                {-1, distance}
              else
                nearest_point
              end
            end
          end)

        if id != -1,
          do: Map.update(acc, id, 1, &(&1 + 1)),
          else: acc
      end)
    end)
    |> Enum.reduce([], fn {id, size}, acc ->
      IO.inspect(id_points)

      case Map.get(id_points, id) do
        {_, _, :edge} -> acc
        _ -> [{id, size}]
      end
    end)
    |> Enum.max_by(fn {id, size} -> size end)
  end

  defp mark_points(points, {min_x, max_x, min_y, max_y}) do
    {_, points} =
      Enum.reduce(points, {-1, %{}}, fn point, acc ->
        marke_edge(point, {min_x, min_y}, acc)
      end)

    IO.inspect(points)

    {_, points} =
      Enum.reduce(points, {-1, %{}}, fn point, acc ->
        marke_edge(point, {min_x, max_y}, acc)
      end)

    {_, points} =
      Enum.reduce(points, {-1, %{}}, fn point, acc ->
        marke_edge(point, {max_x, max_y}, acc)
      end)

    {_, points} =
      Enum.reduce(points, {-1, %{}}, fn point, acc ->
        marke_edge(point, {max_x, min_y}, acc)
      end)

    points
  end

  defp marke_edge({_, {{x, y}, _}} = point, _, {_, map}) do
    IO.puts("point")
    IO.inspect(point)
    IO.inspect(map)
    map
  end

  defp marke_edge({id, point}, corner, nearest) do
    IO.inspect({id, point})
    {distance, points_to_keep} = nearest

    coordinates =
      case point do
        {{x, y}, _} -> {x, y}
        coord -> coord
      end

    # IO.inspect(point)
    # IO.inspect(coordinates)
    distance_from_point = manhattan_distance(corner, coordinates)

    if distance_from_point < distance or distance == -1 do
      {distance_from_point, Map.put(points_to_keep, id, {coordinates, :edge})}
    else
      {distance, Map.put(points_to_keep, id, coordinates)}
    end
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def identify(input) do
    {_, indentified_points} =
      input
      |> Enum.reduce({0, %{}}, fn point, {last_id, acc} ->
        {last_id + 1, Map.put(acc, last_id + 1, point)}
      end)

    indentified_points
  end

  def grid_edges(input) do
    input
    |> Enum.reduce({0, 0, 0, 0}, fn {x, y}, acc ->
      {min_x, max_x, min_y, max_y} = acc
      min_x = if x < min_x, do: x, else: min_x
      max_x = if x > max_x, do: x, else: max_x
      min_y = if y < min_y, do: y, else: min_y
      max_y = if y > max_y, do: y, else: max_y

      {min_x, max_x, min_y, max_y}
    end)
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
    assert PartOne.solve([{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]) == 17
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
