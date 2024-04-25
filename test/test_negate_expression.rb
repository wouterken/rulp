require_relative 'test_helper'

class NegateExpressionTest < Minitest::Test

  def test_negate_expression
    @problem = Rulp::Max(- (X1_i + 2 * X2_i))
    @problem[
       X1_i + X2_i == 10,
       X1_i >= 0,
       X2_i >= 0
    ]

    @problem.solve
    assert X1_i.value == 10
    assert X2_i.value == 0
  end

  def test_double_negate_expression
    @problem = Rulp::Max(-(-(X1_i + 2 * X2_i)))
    @problem[
       X1_i + X2_i == 10,
       X1_i >= 0,
       X2_i >= 0
    ]

    @problem.solve
    assert X1_i.value == 0
    assert X2_i.value == 10
  end
end
