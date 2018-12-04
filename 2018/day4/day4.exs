Code.load_file("time_frame.exs", "..")

defmodule LogHelper do
  def sort(input) do
    input
    |> Stream.map(&extract_log_entry/1)
    |> Enum.sort(&(NaiveDateTime.compare(&1.date, &2.date) == :lt))
  end

  defp extract_log_entry(line) do
    %{
      "day" => day,
      "month" => month,
      "year" => year,
      "hour" => hour,
      "min" => minute,
      "description" => description
    } =
      Regex.named_captures(
        ~r/\[(?<year>\d+)-(?<month>\d+)-(?<day>\d+) (?<hour>\d+):(?<min>\d+)\] (?<description>.+)/,
        line
      )

    {:ok, date} =
      NaiveDateTime.new(
        String.to_integer(year),
        String.to_integer(month),
        String.to_integer(day),
        String.to_integer(hour),
        String.to_integer(minute),
        0
      )

    %{
      date: date,
      description: description
    }
  end
end

defmodule SolutionPartOne do
  def solve(input) do
    result =
      input
      |> LogHelper.sort()
      |> Enum.reduce(%{}, fn log, acc ->
        Regex.named_captures(
          ~r/Guard #(?<guard_id>\d+) begins shift/,
          log.description
        )
        |> case do
          nil ->
            if log.description == "falls asleep" do
              Map.put(acc, :start_sleep_date, log.date)
            else
              if log.description == "wakes up" and Map.get(acc, :start_sleep_date) do
                sleep_time = NaiveDateTime.diff(log.date, acc.start_sleep_date) - 60

                Map.update(
                  %{acc | start_sleep_date: nil},
                  String.to_atom("guard_#{acc.current_guard}"),
                  [sleep_time],
                  fn sleep_times ->
                    [sleep_time | sleep_times]
                  end
                )
              else
                acc
              end
            end

          %{"guard_id" => guard_id} ->
            if Map.get(acc, :start_sleep_date) do
              sleep_time = NaiveDateTime.diff(log.date, acc.start_sleep_date) - 60

              Map.update(
                %{acc | start_sleep_date: nil, current_guard: guard_id},
                String.to_atom("guard_#{guard_id}"),
                [sleep_time],
                fn sleep_times ->
                  [sleep_time | sleep_times]
                end
              )
            else
              Map.update(acc, :current_guard, guard_id, fn _ -> guard_id end)
            end
        end
      end)
      |> Map.delete(:current_guard)
      |> Map.delete(:start_sleep_date)
      |> Enum.reduce(%{guard: nil, total_sleep_time: 0, sleep_times: []}, fn {guard, sleep_times},
                                                                             acc ->
        current_guard_sleep_time = sleep_times |> Enum.sum()

        if current_guard_sleep_time > acc.total_sleep_time do
          guard_id = Atom.to_string(guard) |> String.split("_") |> Enum.at(1)

          %{
            guard: String.to_integer(guard_id),
            total_sleep_time: current_guard_sleep_time,
            sleep_times: sleep_times
          }
        else
          acc
        end
      end)

    most_repeated_sleep_time =
      result.sleep_times
      |> Enum.sort()
      |> Enum.chunk_by(fn item -> item end)
      |> Enum.sort(&(length(&1) > length(&2)))
      |> Enum.at(0)
      |> Enum.at(0)

    result.guard * most_repeated_sleep_time / 60
  end
end

defmodule SolutionPartTwo do
  def solve(input) do
    input
  end
end

ExUnit.start()

defmodule SolutionTest do
  use ExUnit.Case

  alias SolutionPartOne, as: PartOne
  alias SolutionPartTwo, as: PartTwo

  # test "Part I" do
  #   {:ok, io} =
  #     StringIO.open("""
  #     [1518-11-01 00:00] Guard #10 begins shift
  #     [1518-11-01 23:58] Guard #99 begins shift
  #     [1518-11-01 00:05] falls asleep
  #     [1518-11-01 00:25] wakes up
  #     [1518-11-02 00:40] falls asleep
  #     [1518-11-04 00:02] Guard #99 begins shift
  #     [1518-11-03 00:24] falls asleep
  #     [1518-11-01 00:30] falls asleep
  #     [1518-11-01 00:55] wakes up
  #     [1518-11-04 00:46] wakes up
  #     [1518-11-05 00:45] falls asleep
  #     [1518-11-02 00:50] wakes up
  #     [1518-11-03 00:29] wakes up
  #     [1518-11-03 00:05] Guard #10 begins shift
  #     [1518-11-04 00:36] falls asleep
  #     [1518-11-05 00:55] wakes up
  #     [1518-11-05 00:03] Guard #99 begins shift
  #     """)

  #   assert PartOne.solve(IO.stream(io, :line)) == 240
  # end

  # test "Part II" do
  #   {:ok, io} =
  #     StringIO.open("""
  #     #1 @ 1,3: 4x4
  #     #2 @ 3,1: 4x4
  #     #3 @ 5,5: 2x2
  #     """)

  #   assert PartTwo.solve(IO.stream(io, :line)) == 3
  # end
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

    # IO.puts("\nPart II")

    # TimeFrame.execute "Part II", :milliseconds do
    #   input
    #   |> SolutionPartTwo.solve()
    #   |> IO.puts()
    # end
  end

  def sort do
    input =
      "input.txt"
      |> File.stream!([], :line)
      |> LogHelper.sort()
      |> Enum.map(fn item -> IO.inspect(item) end)
  end
end

Day.run()
