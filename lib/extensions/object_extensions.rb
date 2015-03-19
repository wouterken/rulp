##
# Object extension to allow numbered LP variables to be initialised dynamically using the following
# syntax.
#
# [Capitalized_varname][lp var type suffix]
#
# Where lp var type suffix is either _b for binary, _i for integer, or _f for float.
# I.e
#
# Rating_i is the equivalent of Rating (type integer)
# Is_happy_b is the equivalent of Is_happy (type binary/boolean)
##
class << Object
  alias_method :old_const_missing, :const_missing
  def const_missing(value)
    method_name = "#{value}".split("::")[-1] rescue ""
    if (("A".."Z").include?(method_name[0]))
      if(method_name.end_with?("b"))
        return BV.send(method_name[0..(method_name[-2] == "_" ? -3 : -2)])
      elsif(method_name.end_with?("i"))
        return IV.send(method_name[0..(method_name[-2] == "_" ? -3 : -2)])
      elsif(method_name.end_with?("f"))
        return LV.send(method_name[0..(method_name[-2] == "_" ? -3 : -2)])
      end
    end
    old_const_missing(value)
  end
end
