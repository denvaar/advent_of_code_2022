initial_crates = {
  ["Z", "P", "B", "Q", "M", "D", "N"],
  ["V", "H", "D", "M", "Q", "Z", "L", "C"],
  ["G", "Z", "F", "V", "D", "R", "H", "Q"],
  ["N", "F", "D", "G", "H"],
  ["Q", "F", "N"],
  ["T", "B", "F", "Z", "V", "Q", "D"],
  ["H", "S", "V", "D", "Z", "T", "M", "Q"],
  ["Q", "N", "P", "F", "G", "M"],
  ["M", "R", "W", "B"]
}

to_int = fn s ->
  s
  |> String.trim()
  |> Integer.parse()
  |> then(fn {n, _whatever} ->
    n
  end)
end

parse_instruction = fn
  <<"move ", s::binary-size(2), "from", a::binary-size(3), "to", b::binary-size(2), "\n">> ->
    {to_int.(s), to_int.(a), to_int.(b)}

  <<"move ", s::binary-size(3), "from", a::binary-size(3), "to", b::binary-size(2), "\n">> ->
    {to_int.(s), to_int.(a), to_int.(b)}
end

top_of_crates = fn crates ->
  {[a | _], [b | _], [c | _], [d | _], [e | _], [f | _], [g | _], [h | _], [i | _]} = crates

  [a, b, c, d, e, f, g, h, i]
  |> Enum.join()
end

"../input.txt"
|> File.stream!()
|> Stream.drop(10)
|> Stream.transform(initial_crates, fn raw_instruction, crates ->
  {count, n_source, n_target} = parse_instruction.(raw_instruction)

  crates =
    Enum.reduce(1..count, crates, fn _i, buckets ->
      source = elem(buckets, n_source - 1)
      target = elem(buckets, n_target - 1)

      [item | source] = source
      target = [item | target]

      buckets
      |> put_elem(n_source - 1, source)
      |> put_elem(n_target - 1, target)
    end)

  {[crates], crates}
end)
|> Enum.to_list()
|> List.last()
|> top_of_crates.()
|> IO.inspect(label: "SOLUTION")
