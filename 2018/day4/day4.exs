Code.load_file("time_frame.exs", "..")

defmodule GuardShiftHelper do
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

  # Falls asleep entry
  def update_state(state, %{description: "falls asleep"} = log_entry),
    do: Map.put(state, :start_sleep_date, log_entry.date)

  # wakes up entry
  def update_state(
        %{start_sleep_date: start_sleep_date} = state,
        %{description: "wakes up"} = log_entry
      )
      when not is_nil(start_sleep_date) do
    sleep_time = div(NaiveDateTime.diff(log_entry.date, state.start_sleep_date), 60) - 1
    first_minute = NaiveDateTime.to_time(start_sleep_date).minute
    last_minute = first_minute + sleep_time

    Map.update(
      %{state | start_sleep_date: nil},
      String.to_atom("guard_#{state.current_guard}"),
      update_asleep_minutes(%{}, first_minute, last_minute),
      fn asleep_minutes ->
        update_asleep_minutes(asleep_minutes, first_minute, last_minute)
      end
    )
  end

  # New Shift entry, but previous guard was sleeping
  def update_state(%{start_sleep_date: start_sleep_date} = state, log_entry)
      when not is_nil(start_sleep_date) do
    guard_id = extract_guard_id(log_entry.new_shift_begins)
    sleep_time = div(NaiveDateTime.diff(log_entry.date, state.start_sleep_date), 60) - 1
    first_minute = NaiveDateTime.to_time(start_sleep_date).minute
    last_minute = first_minute + sleep_time

    Map.update(
      %{state | start_sleep_date: nil, current_guard: guard_id},
      String.to_atom("guard_#{guard_id}"),
      update_asleep_minutes(%{}, first_minute, last_minute),
      fn asleep_minutes ->
        update_asleep_minutes(asleep_minutes, first_minute, last_minute)
      end
    )
  end

  def update_state(state, log_entry) do
    guard_id = extract_guard_id(log_entry.description)
    Map.update(state, :current_guard, guard_id, fn _ -> guard_id end)
  end

  defp extract_guard_id(new_shift_begins) do
    %{"guard_id" => guard_id} =
      Regex.named_captures(
        ~r/Guard #(?<guard_id>\d+) begins shift/,
        new_shift_begins
      )

    guard_id
  end

  defp update_asleep_minutes(map, first_minute, last_minute) do
    first_minute..last_minute
    |> Enum.reduce(map, fn minute, acc ->
      Map.update(acc, "#{rem(minute, 60)}", 1, &(&1 + 1))
    end)
  end
end

defmodule SolutionPartOne do
  import GuardShiftHelper

  def solve(input) do
    result =
      input
      |> sort()
      |> Enum.reduce(%{}, fn log, acc -> update_state(acc, log) end)
      |> Map.delete(:current_guard)
      |> Map.delete(:start_sleep_date)
      |> Enum.reduce(%{guard: nil, sleep_time: 0, most_repeated_minute: -1}, fn {guard,
                                                                                 minutes_asleep},
                                                                                acc ->
        select_most_sleepy_guard(guard, minutes_asleep, acc)
      end)

    result.guard * result.most_repeated_minute
  end

  defp select_most_sleepy_guard(guard, minutes_asleep, acc) do
    minute_counts = minutes_asleep |> Map.values()
    current_guard_sleep_time = minute_counts |> Enum.sum()

    if current_guard_sleep_time <= acc.sleep_time do
      acc
    else
      guard_id = Atom.to_string(guard) |> String.split("_") |> Enum.at(1)

      most_repeated_minute =
        minutes_asleep
        |> Enum.reduce(%{minute: -1, count: -1}, fn {minute, count}, acc ->
          if count > acc.count,
            do: %{minute: String.to_integer(minute), count: count},
            else: acc
        end)

      %{
        guard: String.to_integer(guard_id),
        sleep_time: current_guard_sleep_time,
        most_repeated_minute: most_repeated_minute.minute
      }
    end
  end
end

defmodule SolutionPartTwo do
  import GuardShiftHelper

  def solve(input) do
    result =
      input
      |> sort()
      |> Enum.reduce(%{}, fn log, acc -> update_state(acc, log) end)
      |> Map.delete(:current_guard)
      |> Map.delete(:start_sleep_date)
      |> Enum.reduce(%{guard: nil, max_minute_count: 0, most_repeated_minute: -1}, fn {guard,
                                                                                       minutes_asleep},
                                                                                      acc ->
        select_most_sleepy_guard(guard, minutes_asleep, acc)
      end)

    result.guard * result.most_repeated_minute
  end

  defp select_most_sleepy_guard(guard, minutes_asleep, acc) do
    minute_counts = minutes_asleep |> Map.values()
    current_guard_max_minute_count = minute_counts |> Enum.max()

    if current_guard_max_minute_count <= acc.max_minute_count do
      acc
    else
      guard_id = Atom.to_string(guard) |> String.split("_") |> Enum.at(1)

      most_repeated_minute =
        minutes_asleep
        |> Enum.reduce(%{minute: -1, count: -1}, fn {minute, count}, acc ->
          if count > acc.count,
            do: %{minute: String.to_integer(minute), count: count},
            else: acc
        end)

      %{
        guard: String.to_integer(guard_id),
        max_minute_count: current_guard_max_minute_count,
        most_repeated_minute: most_repeated_minute.minute
      }
    end
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
      [1518-11-01 00:00] Guard #10 begins shift
      [1518-11-01 23:58] Guard #99 begins shift
      [1518-11-01 00:05] falls asleep
      [1518-11-01 00:25] wakes up
      [1518-11-02 00:40] falls asleep
      [1518-11-04 00:02] Guard #99 begins shift
      [1518-11-03 00:24] falls asleep
      [1518-11-01 00:30] falls asleep
      [1518-11-01 00:55] wakes up
      [1518-11-04 00:46] wakes up
      [1518-11-05 00:45] falls asleep
      [1518-11-02 00:50] wakes up
      [1518-11-03 00:29] wakes up
      [1518-11-03 00:05] Guard #10 begins shift
      [1518-11-04 00:36] falls asleep
      [1518-11-05 00:55] wakes up
      [1518-11-05 00:03] Guard #99 begins shift
      """)

    assert PartOne.solve(IO.stream(io, :line)) == 240
  end

  test "Part II" do
    {:ok, io} =
      StringIO.open("""
      [1518-11-01 00:00] Guard #10 begins shift
      [1518-11-01 00:05] falls asleep
      [1518-11-01 00:25] wakes up
      [1518-11-01 00:30] falls asleep
      [1518-11-01 00:55] wakes up
      [1518-11-01 23:58] Guard #99 begins shift
      [1518-11-02 00:40] falls asleep
      [1518-11-02 00:50] wakes up
      [1518-11-03 00:05] Guard #10 begins shift
      [1518-11-03 00:24] falls asleep
      [1518-11-03 00:29] wakes up
      [1518-11-04 00:02] Guard #99 begins shift
      [1518-11-04 00:36] falls asleep
      [1518-11-04 00:46] wakes up
      [1518-11-05 00:03] Guard #99 begins shift
      [1518-11-05 00:45] falls asleep
      [1518-11-05 00:55] wakes up
      """)

    assert PartTwo.solve(IO.stream(io, :line)) == 4455
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

  def sort do
    input =
      "input.txt"
      |> File.stream!([], :line)
      |> GuardShiftHelper.sort()
      |> Enum.map(fn item -> IO.inspect(item) end)
  end
end

Day.run()
