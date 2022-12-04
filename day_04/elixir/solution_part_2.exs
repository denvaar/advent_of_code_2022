parse_line = fn line ->
  line
  |> String.split(",")
  |> Enum.flat_map(fn pair ->
    with [n1, n2] <- String.split(pair, "-"),
         {n1, _} <- Integer.parse(n1),
         {n2, _} <- Integer.parse(n2) do
      [n1, n2]
    end
  end)
end

"../input.txt"
|> File.stream!()
|> Stream.transform(0, fn line, count ->
  [a, b, c, d] = parse_line.(line)

  pair_1 = MapSet.new(a..b)
  pair_2 = MapSet.new(c..d)

  result =
    case MapSet.disjoint?(pair_1, pair_2) do
      true -> count
      false -> count + 1
    end

  {[result], result}
end)
|> Enum.to_list()
|> List.last()
|> IO.inspect(label: "SOLUTION")
