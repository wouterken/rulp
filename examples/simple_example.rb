require_relative "../lib/rulp"

Rulp::Logger::level = :debug
# maximize
#   z = 10 * x + 6 * y + 4 * z
#
# subject to
#   p:      x +     y +     z <= 100
#   q: 10 * x + 4 * y + 5 * z <= 600
#   r:  2 * x + 2 * y + 6 * z <= 300
#
# where all variables are non-negative integers
#   x >= 0, y >= 0, z >= 0
#


given[

X_i >= 0,
Y_i >= 0,
Z_i >= 0

]

result = Rulp::Cbc Rulp::Max( 10 * X_i + 6 * Y_i + 4 * Z_i ) [
                X_i +     Y_i +     Z_i <= 100,
           10 * X_i + 4 * Y_i + 5 * Z_i <= 600,
           2 *  X_i + 2 * Y_i + 6 * Z_i <= 300
]


##
# 'result' is the result of the objective function.
# You can retrieve the values of variables by using the 'value' method
# E.g
#   X_i.value == 32
#   Y_i.value == 67
#   Z_i.value == 0
##