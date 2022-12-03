set_bit = fn <<bitvec::bits()>>, index ->
  <<head::bits-size(index), _::size(1), tail::bits()>> = bitvec
  <<head::bits-size(index), 1::size(1), tail::bits()>>
end

reducer = fn
  c, bits when c == ?\n ->
    bits

  c, bits ->
    index =
      if c >= ?a,
        do: c - ?a,
        else: c - ?A + 26

    set_bit.(bits, index)
end

bin_to_bitvec = fn s ->
  bits =
    for <<(<<i::bits-size(1)>> <-
             <<0::size(52)>>)>>,
        into: <<>>,
        do: i

  s
  |> String.to_charlist()
  |> Enum.reduce(bits, reducer)
end

first_overlap_index = fn index, {bv_a, bv_b, bv_c}, func ->
  <<_offset::bits-size(index), b_a::size(1), _tail::bits()>> = bv_a
  <<_offset::bits-size(index), b_b::size(1), _tail::bits()>> = bv_b
  <<_offset::bits-size(index), b_c::size(1), _tail::bits()>> = bv_c

  case {b_a, b_b, b_c} do
    {1, 1, 1} ->
      index

    {_, _, _} ->
      func.(
        index + 1,
        {bv_a, bv_b, bv_c},
        func
      )
  end
end

"../input.txt"
|> File.stream!()
|> Stream.chunk_every(3)
|> Stream.map(fn [a, b, c] ->
  bitvectors = {bin_to_bitvec.(a), bin_to_bitvec.(b), bin_to_bitvec.(c)}
  first_overlap_index.(0, bitvectors, first_overlap_index) + 1
end)
|> Enum.sum()
|> IO.inspect(label: "SOLUTION")
