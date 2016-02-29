require_relative 'test_helper'

class BasicSuite < Minitest::Test

  def test_single_binary_var
    each_solver do |solver|
      assert_equal X_b.value, nil

      # The minimal value for a single binary variable is 0
      Rulp::Min(X_b).(solver)
      assert_equal X_b.value, false

      # The maximal value for a single binary variable is 1
      Rulp::Max(X_b).(solver)
      assert_equal X_b.value, true

      # If we set an upper bound this is respected by the solver
      Rulp::Max(X_b)[1 * X_b <= 0].(solver)
      assert_equal X_b.value, false

      # If we set a lower bound this is respected by the solver
      Rulp::Min(X_b)[1 * X_b >= 1].(solver)
      assert_equal X_b.value, true
    end
  end

  def test_single_integer_var
    each_solver do |solver|
      assert_equal X_i.value, nil

      given[ -35 <= X_i <= 35 ]

      # Integer variables respect integer bounds
      Rulp::Min(X_i).(solver)
      assert_equal X_i.value, -35

      # Integer variables respect integer bounds
      Rulp::Max(X_i).(solver)
      assert_equal X_i.value, 35
    end
  end

  def test_single_general_var
    each_solver do |solver|
      assert_equal X_f.value, nil

      given[ -345.4321 <= X_f <= 345.4321 ]

      # Integer variables respect integer bounds
      Rulp::Min(X_f).(solver)
      assert_in_delta X_f.value, -345.4321, 0.001

      # Integer variables respect integer bounds
      Rulp::Max(X_f).(solver)
      assert_in_delta X_f.value, 345.4321, 0.001
    end
  end
end