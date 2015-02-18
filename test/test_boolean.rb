require_relative 'test_helper'
##
#
# Given 50 items of varying prices
# Get the minimal sum of 10 items that equals at least $15 dollars
#
##
class BooleanTest < Minitest::Test
  def setup
    @items       = 30.times.map(&Shop_Item_b)
    items_count = @items.sum
    items_costs = @items.map{|item| item * Random.rand(1.0...5.0)}.sum

    @problem =
    Rulp::Min( items_costs ) [
      items_count  >= 10,
      items_costs  >= 15
    ]
  end

  def test_scip
    solution = Rulp::Scip @problem
    selected = @items.select(&:value)
    assert_equal selected.length, 10
    assert_operator solution.round(2), :>=, 15
    assert_operator solution, :<=, 25
  end

  def test_cbc
    solution = Rulp::Cbc @problem
    selected = @items.select(&:value)
    assert_equal selected.length, 10
    assert_operator solution.round(2), :>=, 15
    assert_operator solution, :<=, 25
  end

  def test_glpk
    solution = Rulp::Glpk @problem
    selected = @items.select(&:value)
    assert_equal selected.length, 10
    assert_operator solution.round(2), :>=, 15
    assert_operator solution, :<=, 25
  end
end
