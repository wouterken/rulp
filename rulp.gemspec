lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rulp/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'rulp'
  s.version     = Rulp::VERSION
  s.date        = Date.today
  s.summary     = "Ruby Linear Programming"
  s.description = "A simple Ruby LP description DSL"
  s.authors     = ["Wouter Coppieters"]
  s.email       = 'wc@pico.net.nz'
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["test/**/*"]
  s.executables << 'rulp'
end
