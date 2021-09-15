class Glpk < Solver
  def solve
    glpk_filename = @outfile.chomp(".sol")
    command = "#{executable} --lp #{@filename} %s --cuts --output #{@outfile}"
    command %= "--write #{glpk_filename}glpk.sol --wglp #{glpk_filename}glpk.prob"
    command %= [
      options[:gap] ? "--mipgap #{options[:gap]}" : "",
      options[:time_limit] ? "--tmlim #{options[:time_limit]}" : ""
    ]
    exec(command)
  end

  def self.executable
    :glpsol
  end

  def get_colum_ids(lines)
    column_ids = {}
    lines.each do |line|
      next unless line.start_with?('n j')

      line_values = line.split(' ')
      column_ids[line_values.last] = line_values[-2]
    end
    column_ids
  end

  def get_column_solutions(lines, solution_format)
    column_solutions = {}
    lines.each do |line|
      next unless line.start_with?('j')

      line_values = line.split(' ')
      solution = solution_format.casecmp?('mip') ? line_values.last : line_values[-2]
      column_solutions[line_values[1]] = solution
    end
    column_solutions
  end

  def get_solution_line_data(lines)
    lines.each do |line|
      next unless line.start_with?('s')

      line_values = line.split(' ')
      solution_format = line_values[1]
      solution_status = solution_format.casecmp?('bas') ? line_values[-3] : line_values[-2]
      self.unsuccessful = !['o', 'f'].include?(solution_status)
      objetive_solution = line_values.last
      return [objetive_solution, solution_format]
    end
  end

  def store_results(variables)
    glpk_filename = @outfile.chomp(".sol")
    prob_lines = IO.read(glpk_filename + 'glpk.prob').split("\n")
    sol_lines = IO.read(glpk_filename + 'glpk.sol').split("\n")
    column_ids = get_colum_ids(prob_lines)
    objetive_solution, solution_format = get_solution_line_data(sol_lines)
    column_solutions = get_column_solutions(sol_lines, solution_format)
    variables.each do |var|
      id = column_ids[var&.to_s]
      var.value = column_solutions[id]&.to_f
    end
    objetive_solution&.to_f
  end
end
