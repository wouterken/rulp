require_relative 'test_helper'
##
#
# Given 50 items of varying prices
# Get the minimal sum of 10 items that equals at least $15 dollars
#
##
class InfeasibleTest < Minitest::Test
  def setup
    @items       = 30.times.map(&Shop_Item_b)
    items_count = @items.inject(:+)
    @items_costs = @items.map{|item| item * Random.rand(1.0...5.0)}.inject(:+)

    @problem =
    Rulp::Min( @items_costs ) [
      items_count  >= 10,
      @items_costs  >= 150_000
    ]
  end

  def test_simple
    each_solver do |solver|
      assert_raises RuntimeError do
        @problem.send(solver)
      end
    end
  end
end
