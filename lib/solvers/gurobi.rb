class Gurobi < Solver
  def solve
    command = "#{executable} ResultFile=#{@outfile} %s %s %s #{@filename}"
    command %= [
      options[:gap] ? "MipGap=#{options[:gap]}":"",
      options[:node_limit] ? "NodeLimit=#{options[:node_limit]}":"",
      options[:time_limit] ? "TimeLimit=#{options[:time_limit]}":"",
      ENV['RULP_GUROBI_CMD_ARGS'] ? ENV['RULP_GUROBI_CMD_ARGS'] : ''
    ]
    exec(command)
  end

  def self.executable
    :gurobi_cl
  end

  def store_results(variables)
    text = IO.read(@outfile)
    self.unsuccessful = text.strip.length.zero? || text.downcase.include?('infeasible')
    unless self.unsuccessful
     rows = text.split("\n")
      objective_str = rows[0].split(/\s+/)[-1]
      vars_by_name = {}
      rows[1..-1].each do |row|
        cols = row.strip.split(/\s+/)
        vars_by_name[cols[0].to_s] = cols[1].to_f
      end
      variables.each do |var|
        var.value = vars_by_name[var.to_s].to_f
      end
    end
    return objective_str.to_f
  end
end
