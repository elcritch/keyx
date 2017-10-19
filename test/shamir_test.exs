defmodule KeyX.ShamirTest do
  use ExUnit.Case
  # doctest KeyX

  alias KeyX.Shamir

  test "basic split" do

    secret = "test"

    shares = Shamir.split_secret(3, 5, secret)

    assert length(shares) == 5

    for share <- shares do
      assert  length(:binary.bin_to_list(share)) == length(:binary.bin_to_list(secret)) + 1
    end
  end

  test "basic split & recover" do

    secret = "test"

    shares = Shamir.split_secret(3, 5, secret)

    IO.puts "shares: #{inspect shares}"

    res = Shamir.recover_secret(Enum.slice(shares, 0, 3))

    IO.puts "recover: res: #{inspect res}"
  end


end
