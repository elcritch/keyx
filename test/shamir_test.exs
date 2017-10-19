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

  test "basic recover static short" do

    shares = ["0E4A" |> Base.decode16!, "9954" |> Base.decode16!]
    res = Shamir.recover_secret(shares)

    assert "t" == res
  end

  test "basic recover static long" do
    shares =
        ["C8EF4C4201", "9673E6A402", "2AF9D99203", "992DC30904", "25A7FC3F05"]
        |> Enum.map(&Base.decode16!/1)

    res = Shamir.recover_secret(shares |> Enum.slice(0,3))

    assert "test" == res
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
