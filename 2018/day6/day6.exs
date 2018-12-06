Code.load_file("time_frame.exs", "..")

defmodule SolutionPartOne do
  # {{1, 1}, %{{1,1} => 0, }
  def solve(input) do
    {min_x, max_x, min_y, max_y} = grid_edges(input)
    IO.inspect({min_x, max_x, min_y, max_y})

    id_points =
      input
      |> identify()

    edge_points =
      edge_points(id_points, {min_x, max_x, min_y, max_y})
      |> IO.inspect()

    {id, {infinite, area_size}} =
      Enum.reduce((min_x - 1)..(max_x + 1), %{}, fn x, acc ->
        Enum.reduce((min_y - 1)..(max_y + 1), acc, fn y, acc ->
          {id, _, new_status} =
            id_points
            |> Enum.reduce({-1, -1, false}, fn {id, point}, nearest_point ->
              {nearest_id, distance, status} = nearest_point
              distance_from_point = manhattan_distance({x, y}, point)

              if distance_from_point < distance or distance == -1 do
                # if id == 1 do
                #   IO.inspect({x, y})
                #   IO.inspect(x < min_x or x > max_x or y < min_y or y > max_y)
                # end

                {id, distance_from_point, x < min_x or x > max_x or y < min_y or y > max_y}
              else
                if distance_from_point == distance do
                  {-1, distance, status}
                else
                  nearest_point
                end
              end
            end)

          if id != -1,
            do:
              Map.update(acc, id, {new_status, 1}, fn {status, area_size} ->
                if(not status) do
                  {new_status, area_size + 1}
                else
                  {status, area_size + 1}
                end
              end),
            else: acc
        end)
      end)
      |> IO.inspect()
      |> Enum.filter(fn {id, {infinite, _}} -> not infinite end)
      |> Enum.max_by(fn {id, {_, size}} -> size end)

    area_size
  end

  defp edge_points(points, {min_x, max_x, min_y, max_y}) do
    [{min_x, min_y}, {min_x, max_y}, {max_x, min_y}, {max_x, max_y}]
    |> Enum.reduce(MapSet.new([]), fn edge, acc ->
      Enum.reduce(points, {-1, []}, fn {id, coord}, nearest ->
        distance = manhattan_distance(coord, edge)
        {shortest_distance, ids} = nearest

        if distance < shortest_distance or shortest_distance == -1 do
          {distance, [id | ids]}
        else
          nearest
        end
      end)
      |> IO.inspect()
      |> case do
        {_, []} ->
          acc

        {_, edge_ids} ->
          Enum.reduce(edge_ids, acc, fn edge_id, acc -> MapSet.put(acc, edge_id) end)
      end
    end)
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
    |> Enum.reduce({9_999_999, 0, 9_999_999, 0}, fn {x, y}, acc ->
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
    input =
      "input.txt"
      |> File.stream!()
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.map(fn line ->
        %{"x" => x_value, "y" => y_value} =
          Regex.named_captures(
            ~r/(?<x>\d+), (?<y>\d+)/,
            line
          )

        {String.to_integer(x_value), String.to_integer(y_value)}
      end)

    IO.puts("Part I")

    TimeFrame.execute "Part I", :milliseconds do
      input
      |> SolutionPartOne.solve()
      |> IO.puts()
    end

    # IO.puts("\nPart II")

    # TimeFrame.execute "Part II", :milliseconds do
    #   input
    #   |> SolutionPartTwo.solve()
    #   |> IO.puts()
    # end
  end
end

Day.run()
