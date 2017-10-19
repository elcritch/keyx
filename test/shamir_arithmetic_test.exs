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

  test "random polynomial? " do
    poly = Arithmetic.polynomial(42, 2)

    assert [42 | res] = poly
    assert length(res) == 2
  end

  test "poly evaluate simple" do

    poly = Arithmetic.polynomial(42, 1)

    assert Arithmetic.evaluate(poly, 0) == 42
  end

  test "poly evaluate advanced" do

    poly = Arithmetic.polynomial(42, 1)

    res_poly = Arithmetic.evaluate(poly, 1)
    res_exp = Arithmetic.+(42, Arithmetic.*(1, Enum.at(poly,1) ))

    assert res_poly == res_exp
  end

  test "poly random" do

    for i <- 0..255 do

      poly = Arithmetic.polynomial(i,2)

      x_vals = [1, 2, 3]
      y_vals = x_vals |> Enum.map(&(Arithmetic.evaluate(poly, &1)))

      out = Arithmetic.interpolate(x_vals, y_vals, 0)

      assert out == i
    end
  end

end
