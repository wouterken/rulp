# frozen_string_literal: true

##
# An LP Expression constraint. A mathematical expression of which the result
# must be constrained in some way.
##
class Constraint
  def initialize(*constraint_expression)
    @expressions , @constraint_op, @value = constraint_expression
  end

  def variables
    @expressions.variables
  end

  def to_s
    return "#{@expressions} #{constraint_op} #{@value}"
  end

  def constraint_op
    case "#{@constraint_op}"
    when "=="
      "="
    when "<"
      "<="
    when ">"
      ">="
    else
      @constraint_op
    end
  end
end