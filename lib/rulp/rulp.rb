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
GUROBI = "gurobi_cl"

module Rulp
  attr_accessor :expressions
  MIN = "Minimize"
  MAX = "Maximize"

  GLPK  = ::GLPK
  GUROBI  = ::GUROBI
  SCIP  = ::SCIP
  CBC   = ::CBC

  SOLVERS = {
    GLPK     => Glpk,
    SCIP     => Scip,
    CBC      => Cbc,
    GUROBI   => Gurobi,
  }

  def self.Glpk(lp, opts={})
    lp.solve_with(GLPK, opts)
  end

  def self.Cbc(lp, opts={})
    lp.solve_with(CBC, opts)
  end

  def self.Scip(lp, opts={})
    lp.solve_with(SCIP, opts)
  end

  def self.Gurobi(lp, opts={})
    lp.solve_with(GUROBI, opts)
  end

  def self.Max(objective_expression)
    "Creating maximization problem".log :info
    Problem.new(Rulp::MAX, objective_expression)
  end

  def self.Min(objective_expression)
    "Creating minimization problem".log :info
    Problem.new(Rulp::MIN, objective_expression)
  end

  def self.solver_exists?(solver_name)
    solver = solver_name[0].upcase + solver_name[1..-1].downcase
    solver_class = ObjectSpace.const_defined?(solver) && ObjectSpace.const_get(solver)
    solver_class.exists? if(solver_class)
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

    def solve(opts={})
      Rulp.send(self.solver, self, opts)
    end

    def method_missing(method_name, *args)
      self.call(method_name, *args)
    end

    def solver(solver=nil)
      solver = solver || ENV["SOLVER"] || "Scip"
      solver = solver[0].upcase + solver[1..-1].downcase
    end

    def call(using=nil, options={})
      Rulp.send(self.solver(using), self, options)
    end

    def constraints
      constraints_str = @constraints.map.with_index{|constraint, i|
        " c#{i}: #{constraint}"
      }.join("\n").strip
      if constraints_str.empty?
        "0 #{@variables.first} = 0"
      else
        "  #{constraints_str}"
      end
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
        next unless var.bounds
        " #{var.bounds}"
      }.compact.join("\n")
    end

    def get_output_filename
      "/tmp/rulp-#{Random.rand(0..1000)}.lp"
    end

    def output(filename=choose_file)
      IO.write(filename, self)
    end

    def solve_with(type, options={})
      filename = get_output_filename
      solver = SOLVERS[type].new(filename, options)

      "Writing problem".log(:info)
      IO.write(filename, self)

      `open #{filename}` if options[:open_definition]

      "Solving problem".log(:info)
      _, time = _profile{ solver.solve }

      `open #{solver.outfile}` if options[:open_solution]

      "Solver took #{time}".log(:debug)

      "Parsing result".log(:info)
      solver.store_results(@variables)

      result = @objective_expression.evaluate

      "Objective: #{result}\n#{@variables.map{|v|[v.name, "=", v.value].join(' ') if v.value}.compact.join("\n")}".log(:debug)
      return result
    end

    def inspect
      to_s
    end

    def to_s
      %Q(
#{'  '*0}#{@objective}
#{'  '*0} obj: #{@objective_expression}
#{'  '*0}Subject to
#{'  '*0}#{constraints}
#{'  '*0}Bounds
#{'  '*0}#{bounds}#{integers}#{bits}
#{'  '*0}End
      )
    end

    alias_method :save, :output
  end
end
