class Gurobi < Solver
  def solve(options)
    command = "gurobi_cl ResultFile=#{@outfile} #{@filename}"
    command %= options[:gap] ? "MipGap=#{options[:gap]}":""
    system(command)
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
      vars_by_name[cols[0].to_s] = cols[1].to_f
    end
    variables.each do |var|
      var.value = vars_by_name[var.to_s].to_f
    end
    return objective
  end
end
