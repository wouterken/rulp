class Cbc < Solver
  def solve(open_solution=false)
    system("#{executable} #{@filename} branch solution #{@outfile}")
    `open #{@outfile}` if open_solution
  end

  def self.executable
    :cbc
  end

  def store_results(variables)
    rows = IO.read(@outfile).split("\n")
    objective = rows[0].split(/\s+/)[-1].to_f
    vars_by_name = {}
    rows[1..-1].each do |row|
      cols = row.strip.split(/\s+/)
      vars_by_name[cols[1].to_s] = cols[2].to_f
    end
    variables.each do |var|
      var.value = vars_by_name[var.name.to_s].to_f
    end
    return objective
  end
end
