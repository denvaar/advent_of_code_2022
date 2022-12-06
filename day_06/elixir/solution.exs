input = "../input.txt" |> File.read!()

Enum.reduce_while(3..1_000_000, input, fn pos, s ->
  <<chunk::binary-size(4), _rest::binary()>> = s

  <<_::binary-size(1), next::binary()>> = s

  set =
    chunk
    |> String.split("", trim: true)
    |> MapSet.new()

  case MapSet.size(set) == String.length(chunk) and pos >= 4 do
    true -> {:halt, pos + 1}
    false -> {:cont, next}
  end
end)
|> IO.inspect(label: "SOLUTION")
