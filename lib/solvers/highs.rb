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
    self.model_status = rows[1]

    if model_status.downcase.include?('infeasible')
      self.unsuccessful = true
      return
    end

    columns_idx = rows.index { |r| r.match?(/# Columns/) }
    rows_idx = rows.index { |r| r.match?(/# Rows/) }

    vars_by_name = {}

    rows[(columns_idx + 1)...rows_idx].each do |row|
      var_name, var_value = row.strip.split(/\s+/)
      vars_by_name[var_name] = var_value
    end

    variables.each do |var|
      var.value = vars_by_name[var.to_s].to_f
    end

    rows.find { |r| r.match?(/Objective/) }.to_s.split(/\s+/).last.to_f
  end
end
