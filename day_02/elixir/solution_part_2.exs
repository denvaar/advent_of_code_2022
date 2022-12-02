parse_line = fn <<a::binary-size(1), " ", expected_outcome::binary-size(1), "\n">> ->
  wins = %{"A" => 2, "B" => 3, "C" => 1}
  draws = %{"A" => 1, "B" => 2, "C" => 3}
  losses = %{"A" => 3, "B" => 1, "C" => 2}

  case expected_outcome do
    "X" ->
      losses
      |> Map.get(a)
      |> Kernel.+(0)

    "Y" ->
      draws
      |> Map.get(a)
      |> Kernel.+(3)

    "Z" ->
      wins
      |> Map.get(a)
      |> Kernel.+(6)
  end
end

"../input.txt"
|> File.stream!()
|> Stream.map(&parse_line.(&1))
|> Enum.sum()
|> IO.inspect(label: "SOLUTION")
