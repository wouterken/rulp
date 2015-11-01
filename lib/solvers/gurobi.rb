class Gurobi < Solver
  def solve
    command = "#{executable} ResultFile=#{@outfile} %s %s #{@filename}"
    command %= [
      options[:gap] ? "MipGap=#{options[:gap]}":"",
      options[:node_limit] ? "NodeLimit=#{options[:node_limit]}":""
    ]
    exec(command)
  end

  def self.executable
    :gurobi_cl
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
