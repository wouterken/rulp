class Solver
  def initialize(filename)
    @filename = filename
    @outfile = "/tmp/#{executable}-output.txt"
    raise Exception.new("Couldn't find solver #{executable}!") if `which #{executable}`.length == 0
    @solver_exists = true
  end

  def store_results(variables)
    puts "Not yet implemented"
  end

  def solver_exists?
    @solver_exists || false
  end
end

require_relative 'cbc'
require_relative 'scip'
require_relative 'glpk'
