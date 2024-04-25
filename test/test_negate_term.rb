require_relative 'test_helper'

class NegateTerm < Minitest::Test
  def setup
    @problem = Rulp::Max(-X1_i + 2 * X2_i)
    @problem[
      X1_i + X2_i == 10,
      X1_i >= 0,
      X2_i >= 0
    ]

    @problem.solve
  end

  def test_negate_term
    assert X1_i.value == 0
    assert X2_i.value == 10
  end
end
