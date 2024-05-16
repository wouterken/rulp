class Highs < Solver
  def solve
    command = "#{executable} --model_file #{@filename} --solution_file #{@outfile}"
    command %= [
      options[:time_limit] ? "--time_limit #{options[:time_limit]}" : ''
    ]
    exec(command)
  end

  def self.executable
    :highs
  end

  def store_results(variables)
    rows = IO.read(@outfile).split("\n")

    if rows[1].include?('Infeasible')
      self.unsuccessful = true
      return
    end

    columns_idx = rows.index { |r| r.match?(/# Columns/) }
    rows_idx = rows.index { |r| r.match?(/# Rows/) }

    vars_by_name = {}

    rows[(columns_idx.to_i + 1)...rows_idx.to_i].each do |row|
      var_name, var_value = row.strip.split(/\s+/)
      vars_by_name[var_name] = var_value
    end

    variables.each do |var|
      var.value = vars_by_name[var.to_s].to_f
    end

    rows.find { |r| r.match?(/Objective/) }.to_s.split(/\s+/).last.to_f
  end
end
