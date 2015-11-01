class Cbc < Solver
  def solve
    if options[:parallel]
      command =  "#{executable} #{@filename} %s %s threads 8 branch solution #{@outfile}"
    else
      command =  "#{executable} #{@filename} %s %s branch solution #{@outfile}"
    end
    command %= [
      options[:gap] ? "ratio #{options[:gap]}":"",
      options[:node_limit] ? "maxN #{options[:node_limit]}":""
    ]

    exec(command)
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
      var.value = vars_by_name[var.to_s].to_f
    end
    return objective
  end
end
