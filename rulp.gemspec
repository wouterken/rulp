Gem::Specification.new do |s|
  s.name        = 'rulp'
  s.version     = '0.0.36'
  s.date        = Date.today
  s.summary     = "Ruby Linear Programming"
  s.description = "A simple Ruby LP description DSL"
  s.authors     = ["Wouter Coppieters"]
  s.email       = 'wc@pico.net.nz'
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["test/**/*"]
  s.executables << 'rulp'
end