defmodule KeyX.Shamir do
  # import Kernel, except: [+: 2, *: 2, /: 2]
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
    shares_init = for _ <- 1..n, do: []

    shares = Enum.reduce :binary.bin_to_list(secret), shares_init, fn(val, shares) ->
      IO.puts "\n\nshamir:reduc: val: #{val} shares: #{inspect shares |> Enum.map(&( to_string(&1) <> <<0>> ))}"
      IO.puts "shamir:reduc: Enum.zip(x_coorinates, shares): #{inspect Enum.zip(x_coorinates, shares)}"
      IO.puts "shamir:reduc: x_coorinates: #{ inspect x_coorinates}"

      poly = KeyX.Shamir.Arithmetic.polynomial(val, k-1)

      res = for {x,x_acc} <- Enum.zip(x_coorinates, shares), into: [] do
        [ x_acc, KeyX.Shamir.Arithmetic.evaluate(poly, x) ]
      end

      IO.puts "shamir:reduc: res: #{res}"

      res
    end

    IO.puts "shamir: shares: #{inspect shares}"
    for {share,x} <- Enum.zip(shares, x_coorinates), into: [] do
      res = :binary.list_to_bin([share, (x + 1) ])
      IO.puts "shamir: res: #{inspect res}"
      res
    end
  end

  @spec secret_recover( list(binary) ) :: binary
  def secret_recover(shares) do
    # Constants
    [ size, other_sz ] = for share <- shares, into: MapSet.new, do: length(share)
    y_len = size - 1
    x_samples = for share <- shares, do: List.last(share)

    # Error checking
    unless [] = other_sz, do: raise "shares must match in size"
    unless length(x_samples) == length(MapSet.new(x_samples)), do: raise "Duplicated shares"

    # Evaluate polynomials and return secret!
    for share <- shares, into: "" do
      << y_samples :: binary-size(y_len) , x :: binary-size(1) >> = share

      KeyX.Shamir.Arithmetic.interpolate_polynomial(x_samples, y_samples, 0)
    end
  end


  def set_random_seed() do
    # https://hashrocket.com/blog/posts/the-adventures-of-generating-random-numbers-in-erlang-and-elixir
    << i1 :: unsigned-integer-32, i2 :: unsigned-integer-32, i3 :: unsigned-integer-32>> = :crypto.strong_rand_bytes(12)
    :rand.seed(:exsplus, {i1, i2, i3})
  end

  def rand_shuffle(list) do
    list |> Enum.sort_by( fn _x -> :rand.uniform() end )
  end

end
