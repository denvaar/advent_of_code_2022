sum_elf_calories = fn calories ->
  Enum.reduce(calories, 0, fn calories, elf_total_calories ->
    case Integer.parse(calories) do
      {calories, _} -> calories + elf_total_calories
      :error -> elf_total_calories
    end
  end)
end

"../input.txt"
|> File.stream!()
|> Stream.chunk_by(fn line -> line == "\n" end)
|> Stream.transform(0, fn raw_elf_data_chunk, max_calories_so_far ->
  chunk_sum = sum_elf_calories.(raw_elf_data_chunk)

  if chunk_sum > max_calories_so_far do
    {[chunk_sum], chunk_sum}
  else
    {[max_calories_so_far], max_calories_so_far}
  end
end)
|> Stream.take(-1)
|> Enum.to_list()
|> IO.inspect(label: "SOLUTION")
