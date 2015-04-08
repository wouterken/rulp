class Solver
  attr_reader :options, :outfile

  def initialize(filename, options)
    @options = options
    @filename = filename
    @outfile = get_output_filename
    raise StandardError.new("Couldn't find solver #{executable}!") if `which #{executable}`.length == 0
    @solver_exists = true
  end

  def get_output_filename
    "/tmp/rulp-#{Random.rand(0..1000)}.sol"
  end

  def store_results(variables)
    puts "Not yet implemented"
  end

  def executable
    self.class.executable
  end

  def solver_exists?
    @solver_exists || false
  end

  def self.exists?
    return `which #{self.executable}`.length != 0
  end
end

require_relative 'cbc'
require_relative 'scip'
require_relative 'glpk'
require_relative 'gurobi'
