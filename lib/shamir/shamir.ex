defmodule KeyX.Shamir do
  # import Kernel, except: [+: 2, *: 2, /: 2]
  import Bitwise
  import Enum, only: [at: 2, reduce: 2]

  @spec split_secret(non_neg_integer, non_neg_integer, binary) :: list(binary)
  def split_secret(k, n, secret) when n > 255, do: raise "too many parts, n <= 255"
  def split_secret(k, n, secret) when k > n, do: raise "k cannot be less than total shares"
  def split_secret(k, n, secret) when k < 2, do: raise "k cannot be less than 2"
  def split_secret(k, n, secret) when length(secret) == 0, do: raise "secret cannot be zero"
  def split_secret(k, n, secret) do
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
      # IO.puts "\n\nshamir:reduc: val: #{val} shares: #{inspect shares |> Enum.map(&( to_string(&1) <> <<0>> ))}"
      # IO.puts "shamir:reduc: Enum.zip(x_coorinates, shares): #{inspect Enum.zip(x_coorinates, shares)}"
      # IO.puts "shamir:reduc: x_coorinates: #{ inspect x_coorinates}"

      poly = KeyX.Shamir.Arithmetic.polynomial(val, k-1)

      res = for {x,x_acc} <- Enum.zip(x_coorinates, shares), into: [] do
        [ x_acc, KeyX.Shamir.Arithmetic.evaluate(poly, x) ]
      end

      # IO.puts "shamir:reduc: res1: #{inspect res}"

      res
    end

    # IO.puts "shamir: shares: #{inspect shares}"
    for {share,x} <- Enum.zip(shares, x_coorinates), into: [] do
      res = :binary.list_to_bin([share, (x + 1) ])
      # IO.puts "shamir: res2: #{inspect res}"
      res
    end
  end

  @spec recover_secret( list(binary) ) :: binary
  def recover_secret(shares) do
    # Constants
    shares = Enum.map(shares, &:binary.bin_to_list/1)
    IO.puts "recover: shares input: #{inspect shares}"
    sizes = for share <- shares, into: [], do: length(share)
    [ size | other_sz ] = sizes |> Enum.uniq

    y_len = size - 1
    x_samples = for share <- shares, do: List.last(share)

    IO.puts "recover: shares: y_len: #{y_len}"
    # Error checking
    unless [] = other_sz, do: raise "shares must match in size"
    unless length(x_samples) == MapSet.size(MapSet.new(x_samples)), do: raise "Duplicated shares"

    # Evaluate polynomials and return secret!
    res = for idx <- 0..(y_len-1), into: [] do

      y_samples = for share <- shares, into: [] do
        share |> Enum.at(idx)
      end

      IO.puts "recover: idx; #{idx} x_samples: #{x_samples|>Enum.join(" ")} y_samples: #{y_samples|>Enum.join(" ")}"

      res = KeyX.Shamir.Arithmetic.interpolate(x_samples, y_samples, 0)
      IO.puts "recover: res: interp: #{inspect res}\n\n"
      res
    end

    res |> :binary.list_to_bin
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
