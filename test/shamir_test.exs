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

  test "basic recover static" do

    shares = ["0E4A" |> Base.decode16!, "9954" |> Base.decode16!]
    res = Shamir.recover_secret(shares)

    assert "t" == res
  end

  test "basic split & recover short" do
    secret = "t"
    shares = Shamir.split_secret(2, 2, "t")

    res = Shamir.recover_secret(shares)
    assert secret == res
  end

  test "basic split & recover long" do
    secret = "super secret"
    shares = Shamir.split_secret(2, 4, secret)

    res = Shamir.recover_secret(shares |> Enum.slice(0,2))

    assert secret == res
  end


  def hexes(share), do: share |> Base.encode16 |> String.downcase
end
