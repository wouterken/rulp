class Scip < Solver
  def self.executable
    :scip
  end

  def solve
    settings = settings_file
    if options[:parallel]
      exec("touch /tmp/fscip_params")
      exec("rm #{@outfile}")
      command = "fscip /tmp/fscip_params #{@filename} -fsol #{@outfile} -s #{settings}"
    else
      exec("rm #{@outfile}")
      command = "#{executable} -f #{@filename} -l #{@outfile} -s #{settings}"
    end
    exec(command)
  end

  def settings_file
    existing_settings = if File.exist?("./scip.set")
       IO.read("./scip.set")
    else
      ""
    end
    if options[:node_limit]
      existing_settings += "\nlimits/nodes = #{options[:node_limit]}"
    end
    if options[:gap]
      existing_settings += "\nlimits/gap   = #{options[:gap]}"
    end
    if options[:time_limit]
      existing_settings += "\nlimits/time   = #{options[:time_limit]}"
    end

    settings_file = get_settings_filename
    IO.write(settings_file, existing_settings)
    return settings_file
  end

  def get_settings_filename
    "/tmp/rulp-#{Random.rand(0..1000)}.set"
  end

  def store_results(variables)
    results  = IO.read(@outfile)
    start    = results.sub(/.*?primal solution.*?=+/m, "")
    stripped = start.sub(/Statistics.+/m, "").strip
    rows     = stripped.split("\n")

    objective_str = rows[options[:parallel] ? 1 : 0].split(/\s+/)[-1]

    vars_by_name = {}
    rows[1..-1].each do |row|
      cols = row.strip.split(/\s+/)
      vars_by_name[cols[0].to_s] = cols[1].to_f
    end
    variables.each do |var|
      var.value = vars_by_name[var.to_s].to_f
    end
    self.unsuccessful = !(Float(objective_str) rescue false)
    return objective_str.to_f
  end
end