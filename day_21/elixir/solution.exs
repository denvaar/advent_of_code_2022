defmodule Solution do
  def solve() do
    "../input.txt"
    |> read_input()
    |> then(fn expressions ->
      evaluate(expressions, expressions["root"])
    end)
    |> floor()
  end

  def evaluate(_expressions, value) when is_number(value), do: value

  def evaluate(expressions, {lhs, operator_func, rhs}) do
    expr1 = expressions[lhs]
    expr2 = expressions[rhs]

    Kernel.apply(operator_func, [
      evaluate(expressions, expr1),
      evaluate(expressions, expr2)
    ])
  end

  defp read_input(path) do
    path
    |> File.read()
    |> then(fn {:ok, data} -> data end)
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn
      <<id::binary-size(4), ": ", _::binary-size(4), " ", _::binary>> = line, acc ->
        Map.merge(acc, %{id => parse_expr(line)})

      <<id::binary-size(4), ": ", value::binary>>, acc ->
        Map.merge(acc, %{id => String.to_integer(value)})
    end)
  end

  defp parse_expr(
         <<_id::binary-size(6), expr1::binary-size(4), " ", operator::binary-size(1), " ",
           expr2::binary-size(4)>>
       ) do
    {expr1, parse_operator(operator), expr2}
  end

  defp parse_operator(op) do
    case op do
      "+" -> fn l_expr, r_expr -> Kernel.+(l_expr, r_expr) end
      "-" -> fn l_expr, r_expr -> Kernel.-(l_expr, r_expr) end
      "/" -> fn l_expr, r_expr -> Kernel./(l_expr, r_expr) end
      "*" -> fn l_expr, r_expr -> Kernel.*(l_expr, r_expr) end
    end
  end
end

Solution.solve()
