require_relative "../lib/rulp"

gem "minitest"
require "minitest/autorun"

Rulp::Logger::level = :off


def each_solver
  [:scip, :cbc, :glpk, :gurobi].each do |solver|
    LV::clear
    if Rulp::solver_exists?(solver)
      yield(solver)
    else
      puts "Couldn't find solver #{solver}"
    end
  end
end