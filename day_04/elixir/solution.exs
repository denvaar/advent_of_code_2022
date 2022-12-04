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
  result =
    case parse_line.(line) do
      [a, b, c, d] when a >= c and b <= d -> count + 1
      [a, b, c, d] when c >= a and d <= b -> count + 1
      [_a, _b, _c, _d] -> count
    end

  {[result], result}
end)
|> Enum.to_list()
|> List.last()
|> IO.inspect(label: "SOLUTION")
