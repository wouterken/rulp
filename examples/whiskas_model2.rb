# Direct translation of the Whiskas Model 2 example from Pulp to Rulp
# https://github.com/coin-or/pulp/blob/master/examples/WhiskasModel2.py
# 
# Usage: SOLVER=Cbc ruby whiskas_model2.rb
# 
require "rulp"

ingredients     = [Chicken_i, Beef_i, Mutton_i, Rice_i, Wheat_i, Gel_i]
costs           = {Chicken: 0.013, Beef: 0.008, Mutton: 0.010, Rice: 0.002, Wheat: 0.005, Gel: 0.001}
protein_percent = {Chicken: 0.100, Beef: 0.200, Mutton: 0.150, Rice: 0.000, Wheat: 0.040, Gel: 0.000}
fat_percent     = {Chicken: 0.080, Beef: 0.100, Mutton: 0.110, Rice: 0.010, Wheat: 0.010, Gel: 0.000}
fibre_percent   = {Chicken: 0.001, Beef: 0.005, Mutton: 0.003, Rice: 0.100, Wheat: 0.150, Gel: 0.000}
salt_percent    = {Chicken: 0.002, Beef: 0.005, Mutton: 0.007, Rice: 0.002, Wheat: 0.008, Gel: 0.000}

objective = ingredients.map{|i| costs[i.name] * i}.inject(:+)
problem = Rulp::Min(objective) 
problem[
  ingredients.inject(:+)                                      == 100,
  ingredients.map{|i| protein_percent[i.name] * i}.inject(:+) >= 8.0,
  ingredients.map{|i| fat_percent[i.name]     * i}.inject(:+) >= 6.0,
  ingredients.map{|i| fibre_percent[i.name]   * i}.inject(:+) <= 2.0,
  ingredients.map{|i| salt_percent[i.name]    * i}.inject(:+) <= 0.4,
]

result = problem.solve

puts "Total Cost Per Can: #{result}"
puts
puts "Chicken: #{Chicken_i.value}"
puts "Beef:    #{Beef_i.value}"
puts "Mutton:  #{Mutton_i.value}"
puts "Rice:    #{Rice_i.value}"
puts "Wheat:   #{Wheat_i.value}"
puts "Gel:     #{Gel_i.value}"
