defmodule KeyX.Shamir.ArithmeticTest do
  use ExUnit.Case
  # doctest KeyX

  alias KeyX.Shamir.Arithmetic

  test "pfield add" do

    assert Arithmetic.+(16,16) == 0
    assert Arithmetic.+(3,4) == 7
    # assert Arithmetic.+(3,4) == 7
  end

  test "pfield mult" do
    assert Arithmetic.*(3,7) == 9
    assert Arithmetic.*(3,0) == 0
    assert Arithmetic.*(0,3) == 0
  end

  test "pfield div" do
    assert Arithmetic./(0,7) == 0
    assert Arithmetic./(3,3) == 1
    assert Arithmetic./(6,3) == 2
  end

end
