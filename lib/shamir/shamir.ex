defmodule KeyX.Shamir do
  import Kernel, except: [+: 2, *: 2]
  import Bitwise

  alias KeyX.Shamir.Tables

  @share_overhead 1

  @type polynomial :: nonempty_list(non_neg_integer)


  @spec polynomial(non_neg_integer, non_neg_integer) :: polynomial
  def polynomial(intercept, degree) do
    [ intercept | :crypto.strong_rand_bytes(degree) |> :binary.bin_to_list() ]
  end


  @spec evaluate(polynomial, non_neg_integer) :: non_neg_integer
  def evaluate(poly, x) when x == 0 do
    Enum.at(poly,0)
  end
  def evaluate(poly, x) do
    degree = length(poly) - 1
    for i <- degree..0 do
    end
  end

  def lhs / rhs when rhs === 0, do: raise ArithmeticError
  def lhs / rhs do
    ret = Kernel.-(Tables.log(lhs), Tables.log(rhs))
      |> Kernel.+(255)
      |> rem(255)
      |> Tables.exp


  end

  # Multiplies two numbers in GF(2^8)
  def lhs * rhs do
    ret = Kernel.+(Tables.log(lhs), Tables.log(rhs))
      |> rem(255)
      |> Tables.exp

    zero = 0

    if (lhs === 0 || rhs === 0), do: zero, else: ret
  end

  @spec evaluate(polynomial, non_neg_integer) :: non_neg_integer
  def lhs + rhs, do: lhs ^^^ rhs

end
