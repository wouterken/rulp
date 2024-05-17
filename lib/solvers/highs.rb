class Highs < Solver
  HIGHS_SUPPORTED_OPTIONS = {
    gap: :mip_rel_gap
  }.freeze

  def solve
    options_file = create_highs_options_file

    command = "#{executable} --model_file #{@filename} --solution_file #{@outfile} %s %s"
    command %= [
      options[:time_limit] ? "--time_limit #{options[:time_limit]}" : '',
      options_file.length.positive? ? "--options_file #{options_file}" : ''
    ]

    exec(command)

    # Remove options file as HiGHS requires additional params in file format instead of command line arguments
    FileUtils.rm(options_file) unless options_file.empty?
  end

  def self.executable
    :highs
  end

  def store_results(variables)
    rows = IO.read(@outfile).split("\n")
    self.model_status = rows[1]

    if model_status.downcase.include?('infeasible') ||
       model_status.downcase.include?('time limit reached')
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

  private

  def create_highs_options_file
    options_str = ''

    HIGHS_SUPPORTED_OPTIONS.each do |rulp_key, highs_key|
      next unless options[rulp_key]

      options_str += "#{highs_key} = #{options[rulp_key]}\n"
    end

    return '' if options_str.empty?

    options_file = "/tmp/highs-#{Random.rand(0..1_000_000)}.opt"
    IO.write(options_file, options_str)

    options_file
  end
end
