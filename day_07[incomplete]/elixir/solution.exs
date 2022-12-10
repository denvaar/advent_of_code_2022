defmodule Wtf do
  def visit_all(m, acc, callback_func) do
    m
    |> Enum.reduce(acc, fn
      {k, v}, acc when is_map(v) ->
        visit_all(v, acc, callback_func)

      {k, v}, acc ->
        callback_func.({k, v}, acc)
    end)
  end
end

parse_instruction = fn
  "$ cd /" ->
    :noop

  "$ cd .." ->
    :prev_directory

  "" ->
    :prev_directory

  <<"$ cd ", dirname::binary()>> ->
    {:next_directory, dirname}

  "$ ls" ->
    :noop

  inst ->
    case Integer.parse(inst) do
      {size, _} -> {:file_size, size}
      :error -> :noop
    end
end

pop_sizes = fn
  [{:size, size} | stack], sum, func ->
    func.(stack, sum + size, func)

  [{:label, label} | stack], sum, _func ->
    {sum, stack}

  [], sum, _func ->
    {sum, []}
end

create_node = fn tree, path ->
  key =
    path
    |> Path.split()
    |> Enum.map(fn x -> Access.key(x) end)

  leaf = %{"size" => 0}

  put_in(tree, key, leaf)
end

set_size = fn tree, path, size ->
  put_in(tree, Path.split(path) ++ ["size"], size)
end

initial = {
  _stack = [],
  _location = "/",
  _tree = %{"/" => %{"size" => 0}},
  _prev_size = 0
}

"../input.txt"
|> File.read!()
|> String.split("\n")
|> Enum.reduce(initial, fn instruction, {stack, location, tree, prev_size} = acc ->
  case parse_instruction.(instruction) do
    {:file_size, size} ->
      {[{:size, size} | stack], location, tree, prev_size}

    {:next_directory, dirname} ->
      location = Path.join(location, dirname)
      {[{:label, location} | stack], location, create_node.(tree, location), prev_size}

    :prev_directory ->
      # p = Path.split(location)
      # IO.inspect(p)
      # IO.inspect({location, prev_size})

      {size, stack} = pop_sizes.(stack, 0, pop_sizes)

      new_location =
        location
        |> Path.split()
        |> case do
          [] -> ["/"]
          other -> other |> Enum.drop(-1)
        end
        |> Enum.join("/")

      {stack, new_location, set_size.(tree, location, size + prev_size), 0}

    _ ->
      acc
  end
end)
|> then(fn initial ->
  stack = elem(initial, 0)

  if Enum.count(stack) > 0 do
    Enum.reduce_while(1..Enum.count(stack), initial, fn _i, {stack, location, tree, prev_size} ->
      IO.inspect({prev_size, stack})
      {size, stack} = pop_sizes.(stack, 0, pop_sizes)

      new_location =
        location
        |> Path.split()
        |> case do
          [] -> ["/"]
          other -> other |> Enum.drop(-1)
        end
        |> Enum.join("/")

      case stack do
        [] ->
          {:halt, {stack, new_location, set_size.(tree, location, size + prev_size), size}}

        stack ->
          {:cont, {stack, new_location, set_size.(tree, location, size + prev_size), 0}}
      end
    end)
    |> elem(2)
  else
    elem(initial, 2)
  end
end)
|> IO.inspect()
|> then(fn dir ->
  Wtf.visit_all(dir, [], fn {k, v}, acc ->
    case {k, v} do
      {"size", v} when v <= 100_000 ->
        [v | acc]

      _others ->
        acc
    end
  end)
  |> then(fn sizes ->
    IO.inspect(sizes)
    Enum.sum(sizes)
  end)
end)
|> IO.inspect()

"""
%{
  "/" => %{
    "a" => %{"e" => %{"size" => 584}, "size" => 94269},
    "d" => %{"size" => 24933642},
    "size" => 23352670
  }
}
"""
