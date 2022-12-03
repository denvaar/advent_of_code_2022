"../input.txt"
|> File.stream!()
|> Stream.map(fn line ->
  len = div(String.length(line) - 1, 2)

  <<match::size(8), _::binary()>> =
    line
    |> String.trim()
    |> String.split_at(len)
    |> then(fn {a, b} ->
      a
      |> String.myers_difference(b)
      |> Keyword.get(:eq)
    end)

  if match >= ?a,
    do: match - ?a + 1,
    else: match - ?A + 27
end)
|> Enum.sum()
|> IO.inspect(label: "SOLUTION")
