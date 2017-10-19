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
    # IO.puts "\n\nshares: a: #{shares|>Enum.at(0)|>hexes} b: #{shares|>Enum.at(1)|>hexes} "

    res = Shamir.recover_secret(shares)

    assert "t" == res
  end

  test "basic split & recover" do

    # IO.puts "<<<<<< basic split & recover"
    secret = "t"
    shares = Shamir.split_secret(2, 2, "t")

    # IO.puts "\n\nshares: a: #{shares|>Enum.at(0)|>hexes} b: #{shares|>Enum.at(1)|>hexes} "

    res = Shamir.recover_secret(shares)

    # IO.puts "==> recover: #{inspect res}"
    # IO.puts "==> recover: #{res |> hexes}"

    assert secret == res
  end


  def hexes(share), do: share |> Base.encode16 |> String.downcase
end
