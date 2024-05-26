class Glpk < Solver
  def solve
    command = "#{executable} --lp #{@filename} %s --cuts --output #{@outfile}"
    command %= [
      options[:gap] ? "--mipgap #{options[:gap]}" : "",
      options[:time_limit] ? "--tmlim #{options[:time_limit]}" : ""
      ].join(" ")
    exec(command)
  end

  def self.executable
    :glpsol
  end

  def store_results(variables)
    rows = IO.read(@outfile).split("\n")
    objective_str = rows[5].split(/\s+/)[-2]
    vars_by_name = {}
    cols = []
    rows[1..-1].each do |row|
      cols.concat(row.strip.split(/\s+/))
      if cols.length > 4
        vars_by_name[cols[1].to_s] = cols[3].to_f
        cols = []
      end
    end
    variables.each do |var|
      var.value = vars_by_name[var.to_s].to_f
    end
    self.unsuccessful = rows[-3].downcase.include?('infeasible')
    return objective_str.to_f
  end
end
