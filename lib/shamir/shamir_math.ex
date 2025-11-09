defmodule KeyX.Shamir.Arithmetic do
  import Kernel, except: [+: 2, *: 2, /: 2]
  import Enum, only: [at: 2]

  alias KeyX.Shamir.Tables

  @type polynomial :: nonempty_list(non_neg_integer)

  @spec polynomial(non_neg_integer, non_neg_integer) :: polynomial
  def polynomial(intercept, degree) do
    [intercept | :crypto.strong_rand_bytes(degree) |> :binary.bin_to_list()]
  end

  @spec evaluate(polynomial, non_neg_integer) :: non_neg_integer
  def evaluate(poly, x) when x === 0 do
    poly |> at(0)
  end

  def evaluate(poly, x) do
    [poly_tail | poly_rest_rev] = Enum.reverse(poly)

    Enum.reduce(poly_rest_rev, poly_tail, fn poly_coef, acc ->
      acc * x + poly_coef
    end)
  end

  def interpolate(x_samples, y_samples, x)
      when length(x_samples) == length(x_samples) do
    # Setup interpolation env
    limit = length(x_samples) - 1

    # Loop through all the x & y samples, reducing them to an answer
    Enum.reduce(0..limit, 0, fn i, result ->
      # skip i == j on inner reduce
      inner_rng = Enum.reject(0..limit, &(&1 == i))

      basis =
        Enum.reduce(inner_rng, 1, fn j, basis ->
          basis *
            ((x + at(x_samples, j)) /
               (at(x_samples, i) + at(x_samples, j)))
        end)

      group = basis * at(y_samples, i)
      result + group
    end)
  end

  def interpolate(_x_samples, _y_samples, _x), do: raise("Invalid arguments")

  def _lhs / rhs when rhs === 0, do: raise(ArithmeticError)

  def lhs / rhs do
    zero = 0

    ret =
      Kernel.-(Tables.log(lhs), Tables.log(rhs))
      |> Kernel.+(255)
      |> rem(255)
      |> Tables.exp()

    if lhs === 0, do: zero, else: ret
  end

  # Multiplies two numbers in GF(2^8)
  def lhs * rhs do
    zero = 0

    ret =
      Kernel.+(Tables.log(lhs), Tables.log(rhs))
      |> rem(255)
      |> Tables.exp()

    if :erlang.or(lhs === 0, rhs === 0), do: zero, else: ret
  end

  # @spec evaluate(polynomial, non_neg_integer) :: non_neg_integer
  # lhs ^^^ rhs
  def lhs + rhs, do: Bitwise.bxor(lhs, rhs)
end
