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

  def exec(command)
    Rulp.exec(command)
  end

  def solver_exists?
    @solver_exists || false
  end

  def self.exists?
    return `which #{self.executable}`.length != 0
  end

  def next_pipe
    filename = "./tmp/_rulp_pipe"
    file_index = 1
    file_index += 1 while File.exists?("#{filename}_#{file_index}")
    pipe = "#{filename}_#{file_index}"
    `mkfifo #{pipe}`
    pipe
  end

  def with_pipe(pipe)
    output = open(pipe, 'w+')
    thread = Thread.new{
      yield output
      output.flush
    }
    return thread, output
  end

end

require_relative 'cbc'
require_relative 'scip'
require_relative 'glpk'
require_relative 'gurobi'
