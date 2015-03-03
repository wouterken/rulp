class Solver
  def initialize(filename)
    @filename = filename
    @outfile = "/tmp/#{executable}-output.txt"
    raise StandardError.new("Couldn't find solver #{executable}!") if `which #{executable}`.length == 0
    @solver_exists = true
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
