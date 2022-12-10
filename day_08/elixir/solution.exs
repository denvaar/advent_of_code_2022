lines =
  "../input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)

max_row =
  lines
  |> Enum.count()
  |> Kernel.-(1)

max_col =
  lines
  |> List.first()
  |> String.length()
  |> Kernel.-(1)

above = fn
  {0, _col} = position -> position
  position -> put_elem(position, 0, elem(position, 0) - 1)
end

below = fn
  {^max_row, _col} = position -> position
  position -> put_elem(position, 0, elem(position, 0) + 1)
end

left_of = fn
  {_row, 0} = position -> position
  position -> put_elem(position, 1, elem(position, 1) - 1)
end

right_of = fn
  {_row, ^max_col} = position -> position
  position -> put_elem(position, 1, elem(position, 1) + 1)
end

visible_from_edge? = fn
  {0, _col} -> true
  {_row, 0} -> true
  {^max_row, _col} -> true
  {_row, ^max_col} -> true
  {_row, _col} -> false
end

tree_smaller_than? = fn tree_size, position, table ->
  Map.get(table, position) < tree_size
end

visible_from_top? = fn
  tree_size, {0, _col} = position, table, _func ->
    tree_smaller_than?.(tree_size, position, table)

  tree_size, position, table, func ->
    with true <- tree_smaller_than?.(tree_size, position, table) do
      func.(tree_size, above.(position), table, func)
    end
end

visible_from_bottom? = fn
  tree_size, {^max_row, _col} = position, table, _func ->
    tree_smaller_than?.(tree_size, position, table)

  tree_size, position, table, func ->
    with true <- tree_smaller_than?.(tree_size, position, table) do
      func.(tree_size, below.(position), table, func)
    end
end

visible_from_left? = fn
  tree_size, {_row, 0} = position, table, _func ->
    tree_smaller_than?.(tree_size, position, table)

  tree_size, position, table, func ->
    with true <- tree_smaller_than?.(tree_size, position, table) do
      func.(tree_size, left_of.(position), table, func)
    end
end

visible_from_right? = fn
  tree_size, {_row, ^max_col} = position, table, _func ->
    tree_smaller_than?.(tree_size, position, table)

  tree_size, position, table, func ->
    with true <- tree_smaller_than?.(tree_size, position, table) do
      func.(tree_size, right_of.(position), table, func)
    end
end

table =
  lines
  |> Enum.with_index()
  |> Enum.reduce(Map.new(), fn {line, row_idx}, table ->
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Map.new(fn {tree, col_idx} -> {{row_idx, col_idx}, tree} end)
    |> Map.merge(table)
  end)

table
|> Map.keys()
|> Enum.reduce(0, fn position, sum ->
  tree_size = Map.get(table, position)

  visible? =
    Enum.any?([
      visible_from_edge?.(position),
      visible_from_top?.(tree_size, above.(position), table, visible_from_top?),
      visible_from_bottom?.(tree_size, below.(position), table, visible_from_bottom?),
      visible_from_left?.(tree_size, left_of.(position), table, visible_from_left?),
      visible_from_right?.(tree_size, right_of.(position), table, visible_from_right?)
    ])

  case visible? do
    true -> sum + 1
    false -> sum
  end
end)
|> IO.inspect(label: "SOLUTION")
