class PScip < Solver

  def self.executable
    :fscip
  end

  def solve(open_solution=false)
    command = "touch /tmp/fscip_params; rm #{@outfile}; #{executable} /tmp/fscip_params #{@filename} -fsol #{@outfile}"
    command += " -s ./scip.set" if File.exists?("./scip.set")
    system(command)
    `open #{@outfile}` if open_solution
  end

  def store_results(variables)
    results  = IO.read(@outfile)
    rows     = results.split("\n")

    objective = rows[1].split(/\s+/)[-1].to_f

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