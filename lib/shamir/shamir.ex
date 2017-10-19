defmodule KeyX.Shamir do
  import Kernel, except: [+: 2, *: 2, /: 2]
  import Bitwise
  import Enum, only: [at: 2, reduce: 2]

  @spec secret_split(non_neg_integer, non_neg_integer, binary) :: list(binary)
  def secret_split(k, n, secret) when n > 255, do: raise "too many parts, n <= 255"
  def secret_split(k, n, secret) when k > n, do: raise "k cannot be less than total shares"
  def secret_split(k, n, secret) when k < 2, do: raise "k cannot be less than 2"
  def secret_split(k, n, secret) when length(secret) == 0, do: raise "secret cannot be zero"
  def secret_split(k, n, secret) do
    set_random_seed()

    # Generate random x coordinates
    x_coorinates = 0..254 |> rand_shuffle

    # This is where implementations can differ, presumably. The H.C. Vault developers noted:
    # // Make random polynomials for each byte of the secret
    # // Construct a random polynomial for each byte of the secret.
    #	// Because we are using a field of size 256, we can only represent
    #	// a single byte as the intercept of the polynomial, so we must
    #	// use a new polynomial for each byte.
    # We could use larger numbers (large field set (larger primes?)),
    # but maintaining compatibility is a key goal in this project
    shares = Enum.reduce secret, [], fn(val, shares) ->
      poly = KeyX.Shamir.Arithmetic.polynomial(val, k-1)

      for {x,x_acc} <- Enum.zip(x_coorinates, shares), into: [] do
        [ shares, KeyX.Shamir.Arithmetic.evaluate(x) ]
      end
    end

    for {share,x} <- Enum.zip(shares, x_coorinates), into: [] do
      List.to_string([share | x])
    end
  end

  @spec secret_recover( list(binary) ) :: binary
  def secret_recover(shares) do
    1
  end


  def set_random_seed() do
    # https://hashrocket.com/blog/posts/the-adventures-of-generating-random-numbers-in-erlang-and-elixir
    << i1 :: unsigned-integer-32, i2 :: unsigned-integer-32, i3 :: unsigned-integer-32>> = :crypto.strong_rand_bytes(12)
    :rand.seed(:exsplus, {i1, i2, i3})
  end

  def rand_shuffle(list) when is_list(list) do
    Enum.sort_by( fn _x -> :rand.uniform() end )
  end

end
