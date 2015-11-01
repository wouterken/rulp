require_relative "../lib/rulp"

gem "minitest"
require "minitest/autorun"

Rulp::Logger::level = :off
Rulp::Logger::print_solver_outputs = false

def each_solver
  [:scip, :cbc, :glpk, :gurobi].each do |solver|
    LV::clear
    if Rulp::solver_exists?(solver)
      yield(solver)
    else
      "Couldn't find solver #{solver}".log(:info)
    end
  end
end