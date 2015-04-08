class Glpk < Solver
  def solve(options)
    command = "#{executable} --lp #{@filename} %s --cuts --write #{@outfile}"
    command %= options[:gap] ? "--mipgap #{options[:gap]}" : ""
    system(command)
  end

  def self.executable
    :glpsol
  end

  def store_results(variables)
    rows = IO.read(@outfile).split("\n")
    variables.zip(rows[-variables.count..-1]).each do |var, row|
      cols = row.split(" ")
      var.value = cols[[1, cols.count - 1].min].to_f
    end
    return rows[1].split(" ")[-1]
  end
end