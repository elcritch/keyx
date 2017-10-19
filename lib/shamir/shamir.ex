defmodule KeyX.Shamir do
  import Kernel, except: [+: 2, *: 2, /: 2]
  import Bitwise
  import Enum, only: [at: 2, reduce: 2]

  @spec secret_split(non_neg_integer, non_neg_integer, binary) :: list(binary)
  def secret_split(k, n, secret) do

  end

  @spec secret_recover( list(binary) ) :: binary
  def secret_recover(shares) do

  end
end
