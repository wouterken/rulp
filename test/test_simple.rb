require_relative 'test_helper'
# maximize
#   z = 10 * x + 6 * y + 4 * z
#
# subject to
#   p:      x +     y +     z <= 100
#   q: 10 * x + 4 * y + 5 * z <= 600
#   r:  2 * x + 2 * y + 6 * z <= 300
#
# where all variables are non-negative integers
#   x >= 0, y >= 0, z >= 0
#

class SimpleTest < Minitest::Test
  def setup
    given[ X_i >= 0,  Y_i >= 0,  Z_i >= 0 ]
    @problem =
    Rulp::Max( 10 * X_i + 6 * Y_i + 4 * Z_i ) [
                    X_i +     Y_i +     Z_i <= 100,
               10 * X_i + 4 * Y_i + 5 * Z_i <= 600,
               2 *  X_i + 2 * Y_i + 6 * Z_i <= 300
    ]
  end

  def test_scip
    solution =   Rulp::Scip @problem
    assert_equal X_i.value, 33
    assert_equal Y_i.value, 67
    assert_equal Z_i.value, 0
    assert_equal solution , 732

  end

  def test_cbc
    solution =   Rulp::Cbc @problem
    assert_equal X_i.value, 33
    assert_equal Y_i.value, 67
    assert_equal Z_i.value, 0
    assert_equal solution , 732

  end

  def test_glpk
    solution =   Rulp::Glpk @problem
    assert_equal X_i.value, 33
    assert_equal Y_i.value, 67
    assert_equal Z_i.value, 0
    assert_equal solution , 732
  end
end
