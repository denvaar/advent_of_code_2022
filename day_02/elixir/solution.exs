parse_line = fn <<a::binary-size(1), " ", b::binary-size(1), "\n">> ->
  shape_points = %{"X" => 1, "Y" => 2, "Z" => 3}
  beats = %{"X" => "C", "Y" => "A", "Z" => "B"}
  draws = %{"X" => "A", "Y" => "B", "Z" => "C"}

  outcome_points =
    cond do
      a == Map.get(beats, b) -> 6
      a == Map.get(draws, b) -> 3
      true -> 0
    end

  outcome_points + Map.get(shape_points, b)
end

"../input.txt"
|> File.stream!()
|> Stream.map(&parse_line.(&1))
|> Enum.sum()
|> IO.inspect(label: "SOLUTION")
