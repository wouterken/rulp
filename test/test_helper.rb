require_relative "../lib/rulp"
require 'logger'

gem "minitest"
require "minitest/autorun"

Rulp::log_level = Logger::UNKNOWN
Rulp::print_solver_outputs = false

def each_solver
  [:scip, :cbc, :glpk, :gurobi].each do |solver|
    LV::clear
    if Rulp::solver_exists?(solver)
      yield(solver)
    else
      Rulp::log(Logger::INFO, "Couldn't find solver #{solver}")
    end
  end
end