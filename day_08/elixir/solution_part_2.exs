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

score_from_edge = fn
  {0, _col} -> 0
  {_row, 0} -> 0
  {^max_row, _col} -> 0
  {_row, ^max_col} -> 0
  {_row, _col} -> 1
end

tree_smaller_than? = fn tree_size, position, table ->
  Map.get(table, position) < tree_size
end

score_from_top = fn
  _tree_size, {0, _col}, _table, score, _func ->
    score + 1

  tree_size, position, table, score, func ->
    case tree_smaller_than?.(tree_size, position, table) do
      true ->
        func.(tree_size, above.(position), table, score + 1, func)

      false ->
        score + 1
    end
end

score_from_bottom = fn
  _tree_size, {^max_row, _col}, _table, score, _func ->
    score + 1

  tree_size, position, table, score, func ->
    case tree_smaller_than?.(tree_size, position, table) do
      true ->
        func.(tree_size, below.(position), table, score + 1, func)

      false ->
        score + 1
    end
end

score_from_left = fn
  _tree_size, {_row, 0}, _table, score, _func ->
    score + 1

  tree_size, position, table, score, func ->
    case tree_smaller_than?.(tree_size, position, table) do
      true ->
        func.(tree_size, left_of.(position), table, score + 1, func)

      false ->
        score + 1
    end
end

score_from_right = fn
  _tree_size, {_row, ^max_col}, _table, score, _func ->
    score + 1

  tree_size, position, table, score, func ->
    case tree_smaller_than?.(tree_size, position, table) do
      true ->
        func.(tree_size, right_of.(position), table, score + 1, func)

      false ->
        score + 1
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
|> Enum.reduce(0, fn position, best_score_so_far ->
  tree_size = Map.get(table, position)

  scenic_score =
    score_from_edge.(position) *
      score_from_top.(tree_size, above.(position), table, 0, score_from_top) *
      score_from_bottom.(tree_size, below.(position), table, 0, score_from_bottom) *
      score_from_left.(tree_size, left_of.(position), table, 0, score_from_left) *
      score_from_right.(tree_size, right_of.(position), table, 0, score_from_right)

  max(scenic_score, best_score_so_far)
end)
|> IO.inspect(label: "SOLUTION")
