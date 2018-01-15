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
    if ("A".."Z").cover?(method_name[0])
      if method_name.end_with?(BV.suffix)
        return BV.definition(method_name.chomp(BV.suffix).chomp("_"))
      elsif method_name.end_with?(IV.suffix)
        return IV.definition(method_name.chomp(IV.suffix).chomp("_"))
      elsif method_name.end_with?(LV.suffix)
        return LV.definition(method_name.chomp(LV.suffix).chomp("_"))
      end
    end
    old_const_missing(value)
  end
end
