class Scip < Solver
  def self.executable
    :scip
  end

  def solve(options)
    system("rm #{@outfile}; #{executable} -f #{@filename} -l #{@outfile} -s ./scip.set")
  end

  def store_results(variables)
    results  = IO.read(@outfile)
    start    = results.sub(/.*?primal solution:.*?=+/m, "")
    stripped = start.sub(/Statistics.+/m, "").strip
    rows     = stripped.split("\n")

    objective = rows[0].split(/\s+/)[-1].to_f

    vars_by_name = {}
    rows[1..-1].each do |row|
      cols = row.strip.split(/\s+/)
      vars_by_name[cols[0].to_s] = cols[1].to_f
    end
    variables.each do |var|
      var.value = vars_by_name[var.to_s].to_f
    end

    return objective
  end
end