Code.load_file("time_frame.exs", "..")

defmodule Star do
  def move({position_x, position_y}, {velocity_x, velocity_y}) do
    {position_x + velocity_x, position_y + velocity_y}
  end

  def isolated?({star_x, star_y}, stars, limit) do
    neighbours_count =
      Enum.reduce((star_x - limit)..(star_x + limit), 0, fn x, acc ->
        Enum.reduce((star_y - limit)..(star_y + limit), acc, fn y, acc ->
          if {x, y} == {star_x, star_y} do
            acc
          else
            if(NightSky.member?(stars, {x, y}),
              do: acc + 1,
              else: acc
            )
          end
        end)
      end)

    neighbours_count == 0
  end
end

defmodule NightSky do
  def stars_aligned?(stars, limit) do
    stars
    |> Enum.reduce_while(true, fn {_, {x, y, _, _}}, _ ->
      if Star.isolated?({x, y}, stars, limit),
        do: {:halt, false},
        else: {:cont, true}
    end)
  end

  def print(stars) do
    {min_x, max_x, min_y, max_y} = boundaries(stars)

    Enum.reduce((min_y - 1)..(max_y + 1), "", fn y, acc ->
      Enum.reduce((min_x - 1)..(max_x + 1), acc, fn x, acc ->
        acc =
          if member?(stars, {x, y}),
            do: acc <> "#",
            else: acc <> "."

        acc <> if x == max_x + 1, do: "\n", else: ""
      end)
    end)
  end

  def member?(stars, {x, y}) do
    Enum.find(stars, fn {_, {star_x, star_y, _, _}} -> x == star_x and y == star_y end)
  end

  def boundaries(stars) do
    {_, {x, y, _, _}} = Enum.at(stars, 0)
    initial_boundary = {x, x, y, y}

    Enum.reduce(stars, initial_boundary, fn {_, {x, y, _, _}}, {min_x, max_x, min_y, max_y} ->
      min_x = if x < min_x, do: x, else: min_x
      max_x = if x > max_x, do: x, else: max_x
      min_y = if y < min_y, do: y, else: min_y
      max_y = if y > max_y, do: y, else: max_y

      {min_x, max_x, min_y, max_y}
    end)
  end

  def build(input) do
    {_, stars} =
      input
      |> Enum.reduce({1, %{}}, fn line, {id, stars} ->
        %{
          "star_x" => star_x,
          "star_y" => star_y,
          "vel_x" => vel_x,
          "vel_y" => vel_y
        } =
          Regex.named_captures(
            ~r/position=<(?<star_x>.+), (?<star_y>.+)> velocity=<(?<vel_x>.+), (?<vel_y>.+)>/,
            line
          )

        star_x = star_x |> String.trim() |> String.to_integer()
        star_y = star_y |> String.trim() |> String.to_integer()
        vel_x = vel_x |> String.trim() |> String.to_integer()
        vel_y = vel_y |> String.trim() |> String.to_integer()

        {id + 1,
         Map.put(
           stars,
           id,
           {star_x, star_y, vel_x, vel_y}
         )}
      end)

    stars
  end

  def print_message(stars) do
    stars_message(stars, 1)
  end

  defp stars_message(stars, time) do
    new_position_stars =
      Enum.reduce(stars, %{}, fn {id, {x, y, vel_x, vel_y}}, acc ->
        {new_pos_x, new_pos_y} = Star.move({x, y}, {vel_x, vel_y})
        Map.put(acc, id, {new_pos_x, new_pos_y, vel_x, vel_y})
      end)

    if NightSky.stars_aligned?(new_position_stars, 1) do
      {time, NightSky.print(new_position_stars)}
    else
      stars_message(new_position_stars, time + 1)
    end
  end
end

defmodule SolutionPartOne do
  def solve(input) do
    {_, message} =
      input
      |> NightSky.build()
      |> NightSky.print_message()

    message
  end
end

defmodule SolutionPartTwo do
  def solve(input) do
    {time, _} =
      input
      |> NightSky.build()
      |> NightSky.print_message()

    time
  end
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne

  test "Part I" do
    input =
      "test_input.txt"
      |> File.stream!([], :line)

    IO.puts(PartOne.solve(input))

    assert """
           ............
           .#...#..###.
           .#...#...#..
           .#...#...#..
           .#####...#..
           .#...#...#..
           .#...#...#..
           .#...#...#..
           .#...#..###.
           ............
           """ == PartOne.solve(input)
  end

  test "Sky boundaries" do
    stars = %{
      1 => {9, 1, 2, 3},
      2 => {7, 0, 2, 3},
      3 => {5, -2, 2, 3}
    }

    assert NightSky.boundaries(stars) == {5, 9, -2, 1}
  end

  test "Print Night Sky" do
    stars = %{
      1 => {9, 1, 2, 3},
      2 => {7, 0, 2, 3},
      3 => {5, -2, 2, 3}
    }

    assert """
           .......
           .#.....
           .......
           ...#...
           .....#.
           .......
           """ == NightSky.print(stars)
  end

  test "Star isolated?" do
    stars = %{
      1 => {9, 1, 2, 3},
      2 => {7, 0, 2, 3},
      3 => {5, -2, 2, 3}
    }

    assert Star.isolated?({7, 0}, stars, 2) == false
    assert Star.isolated?({7, 0}, stars, 1) == true
  end

  test "Stars are aligned" do
    stars = %{
      1 => {9, 1, 2, 3},
      2 => {9, 0, 2, 3}
    }

    assert NightSky.stars_aligned?(stars, 1) == true
  end

  test "Stars are not aligned" do
    stars = %{
      1 => {9, 1, 2, 3},
      2 => {9, 0, 2, 3},
      3 => {5, 1, 2, 3}
    }

    assert NightSky.stars_aligned?(stars, 1) == false
  end

  test "Test parsing" do
    {:ok, io} =
      StringIO.open("""
      position=< 9,  1> velocity=< 0,  2>
      position=< 7,  0> velocity=<-1,  0>
      """)

    assert NightSky.build(IO.stream(io, :line)) == %{1 => {9, 1, 0, 2}, 2 => {7, 0, -1, 0}}
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
