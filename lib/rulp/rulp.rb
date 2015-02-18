require_relative "rulp_bounds"
require_relative "rulp_initializers"
require_relative "lv"
require_relative "constraint"
require_relative "expression"

require_relative "../solvers/solvers"
require_relative "../extensions/extensions"
require_relative "../helpers/log"

require 'set'

GLPK  = "glpsol"
SCIP  = "scip"
CBC   = "cbc"

module Rulp
  attr_accessor :expressions
  MIN = "Minimize"
  MAX = "Maximize"

  GLPK  = ::GLPK
  SCIP  = ::SCIP
  CBC   = ::CBC

  SOLVERS = {
    "glpsol" => Glpk,
    "scip"   => Scip,
    "cbc"    => Cbc
  }

  def self.Glpk(lp)
    lp.solve_with(GLPK)
  end

  def self.Cbc(lp)
    lp.solve_with(CBC)
  end

  def self.Scip(lp)
    lp.solve_with(SCIP)
  end

  def self.Max(objective_expression)
    "Creating maximization problem".log :info
    Problem.new(Rulp::MAX, objective_expression)
  end

  def self.Min(objective_expression)
    "Creating minimization problem".log :info
    Problem.new(Rulp::MIN, objective_expression)
  end

  class Problem
    def initialize(objective, objective_expression)
      @objective = objective
      @variables = Set.new
      @objective_expression = objective_expression.kind_of?(LV) ? 1 * objective_expression : objective_expression
      @variables.merge(@objective_expression.variables)
      @constraints = []
    end

    def [](*constraints)
      @constraints.concat(constraints)
      @variables.merge(constraints.map(&:variables).flatten)
      self
    end

    def constraints
      @constraints.map.with_index{|constraint, i|
        " c#{i}: #{constraint}"
      }.join("\n")
    end

    def integers
      ints = @variables.select{|x| x.kind_of?(IV) }.join(" ")
      return "\nGeneral\n #{ints}" if(ints.length > 0)
    end

    def bits
      bits = @variables.select{|x| x.kind_of?(BV) }.join(" ")
      return "\nBinary\n #{bits}" if(bits.length > 0)
    end

    def bounds
      @variables.map{|var|
        next unless var.bounds_str
        " #{var.bounds_str}"
      }.compact.join("\n")
    end

    def get_output_filename
      "/tmp/rulp-#{Random.rand(0..1000)}.lp"
    end

    def output(filename)
      IO.write(filename, self)
    end

    def solve_with(type, open_definition=false, open_solution=false)
      filename = get_output_filename
      solver = SOLVERS[type].new(filename)

      "Writing problem".log(:info)
      IO.write(filename, self)

      `open #{filename}` if open_definition

      "Solving problem".log(:info)
      _, time = _profile{ solver.solve(open_solution) }

      "Solver took #{time}".log(:info)

      "Parsing result".log(:info)
      solver.store_results(@variables)

      result = @objective_expression.evaluate

      "Objective: #{result}\n#{@variables.map{|v|[v.name, "=", v.value].join(' ') if v.value}.compact.join("\n")}".log(:debug)
      return result
    end

    def to_s
      "\
#{@objective}
 obj: #{@objective_expression}
Subject to
#{constraints}
Bounds
#{bounds}#{integers}#{bits}
End"
    end
  end
end
