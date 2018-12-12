Code.load_file("time_frame.exs", "..")

defmodule Cell do
  def power_level({x, y}, serial_number) do
    rack_id = x + 10
    power_level = (rack_id * y + serial_number) * rack_id
    abs(rem(div(power_level, 100), 10)) - 5
  end
end

defmodule Grid do
  def power_level({x, y}, serial_number, size) do
    Enum.reduce(x..(x + size - 1), 0, fn current_x, acc ->
      Enum.reduce(y..(y + size - 1), acc, fn current_y, acc ->
        acc + Cell.power_level({current_x, current_y}, serial_number)
      end)
    end)
  end

  def square_size_range(x, y) do
    1..min(300 - x, 300 - y)
  end

  def summed_area_table(grid_size, serial_number) do
    Enum.reduce(1..grid_size, %{}, fn x, acc ->
      Enum.reduce(1..grid_size, acc, fn y, acc ->
        Map.put(acc, {x, y}, partial_sum(acc, serial_number, {x, y}))
      end)
    end)
  end

  defp partial_sum(grid, serial_number, {x, y}) do
    Cell.power_level({x, y}, serial_number) + Map.get(grid, {x, y - 1}, 0) +
      Map.get(grid, {x - 1, y}, 0) - Map.get(grid, {x - 1, y - 1}, 0)
  end

  def area_power({x, y}, area_size, summed_area_table) do
    Map.get(summed_area_table, {x, y}, 0) - Map.get(summed_area_table, {x - area_size, y}, 0) -
      Map.get(summed_area_table, {x, y - area_size}, 0) +
      Map.get(summed_area_table, {x - area_size, y - area_size}, 0)
  end
end

defmodule SolutionPartOne do
  # Naive approach (could be solved with Summed Area Table, but that's how I found Part I ;))
  def solve(serial_number, fuel_cells_size) do
    grid_limit = 300 - fuel_cells_size

    Enum.reduce(1..grid_limit, {{0, 0}, 0}, fn x, acc ->
      Enum.reduce(1..grid_limit, acc, fn y, {coord, max_power_level} ->
        current_power_level = Grid.power_level({x, y}, serial_number, fuel_cells_size)

        if current_power_level > max_power_level,
          do: {{x, y}, current_power_level},
          else: {coord, max_power_level}
      end)
    end)
  end
end

defmodule SolutionPartTwo do
  # With Summed Area Table
  def solve(serial_number) do
    summed_area_table = Grid.summed_area_table(300, serial_number)

    Enum.reduce(1..300, {{0, 0}, 0, 0}, fn area_size, acc ->
      Enum.reduce(area_size..300, acc, fn x, acc ->
        Enum.reduce(area_size..300, acc, fn y, acc ->
          {_, max_power, _} = acc

          area_power = Grid.area_power({x, y}, area_size, summed_area_table)

          if area_power > max_power,
            do: {{x - area_size + 1, y - area_size + 1}, area_power, area_size},
            else: acc
        end)
      end)
    end)
  end
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne
  alias SolutionPartTwo, as: PartTwo

  test "Power level for grid" do
    assert Grid.power_level({33, 45}, 18, 3) == 29
    assert Grid.power_level({21, 61}, 42, 3) == 30
  end

  test "Power level for cell" do
    assert Cell.power_level({3, 5}, 8) == 4
    assert Cell.power_level({122, 79}, 57) == -5
    assert Cell.power_level({217, 196}, 39) == 0
    assert Cell.power_level({101, 153}, 71) == 4
  end

  test "Part I" do
    assert PartOne.solve(18, 3) == {{33, 45}, 29}
  end

  # test "Part II" do
  #   assert PartTwo.solve(18) == {{90, 269}, 113, 16}
  # end
end

defmodule Day do
  require TimeFrame

  def run do
    input = 9110

    IO.puts("Part I")

    TimeFrame.execute "Part I", :milliseconds do
      {{x, y}, power_level} =
        input
        |> SolutionPartOne.solve(3)

      IO.puts("Top-Left Fuel Cell: {#{x}, #{y}} (Power Level: #{power_level})")
    end

    IO.puts("\nPart II")

    TimeFrame.execute "Part II", :milliseconds do
      {{x, y}, power_level, area_size} =
        input
        |> SolutionPartTwo.solve()

      IO.puts(
        "Top-Left Fuel Cell: {#{x}, #{y}} || Area-Size: #{area_size} (Power Level: #{power_level})"
      )
    end
  end
end

Day.run()
