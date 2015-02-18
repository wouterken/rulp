##
# An LP Expression. A mathematical expression.
# Can be a constraint or can be the objective function of a LP or MIP problem.
##
class Expressions
  attr_accessor :expressions
  def initialize(expressions)
    @expressions = expressions
  end

  def +(other)
    return Expressions.new(@expressions + [other])
  end

  def to_s
    @expressions.map{|expression|
      [expression.operand < 0 ? " " : " + ", expression.to_s]
    }.flatten[1..-1].join("")
  end

  def variables
    @expressions.map(&:variable)
  end

  [:==, :<, :<=, :>, :>=].each do |constraint_type|
    define_method(constraint_type){|value|
      Constraint.new(self, constraint_type, value)
    }
  end

  def -@
    -self.expressions[0]
    self
  end

  def -(other)
    other = -other
    self + other
  end

  def +(other)
    Expressions.new(self.expressions + Expressions[other].expressions)
  end

  def self.[](value)
    return Expressions.new([Fragment.new(value, 1)]) if value.kind_of?(LV)
    return Expressions.new([value]) if value.kind_of?(Fragment)
    return value if value.kind_of?(Expressions)
  end

  def evaluate
    self.expressions.map(&:evaluate).inject(:+)
  end
end

##
# An expression fragment. An expression can consist of many fragments.
##
class Fragment
  attr_accessor :lv, :operand

  def initialize(lv, operand)
    @lv = lv
    @operand = operand
  end

  def +(other)
    return Expressions.new([self] + Expressions[other].expressions)
  end

  def -(other)
    self.+(-other)
  end

  def *(value)
    Fragment.new(@lv, @operand * value)
  end

  def evaluate
    if [TrueClass,FalseClass].include? @lv.value.class
      @operand * (@lv.value ? 1 : 0)
    else
      @operand * @lv.value
    end
  end

  def -@
    @operand = -@operand
    self
  end

  def variable
    @lv
  end

  [:==, :<, :<=, :>, :>=].each do |constraint_type|
    define_method(constraint_type){|value|
      Constraint.new(Expressions.new(self), constraint_type, value)
    }
  end

  def to_s
    case @operand
    when -1
      "-#{@lv}"
    when 1
      "#{@lv}"
    else
    "#{@operand} #{@lv}"
    end
  end
end