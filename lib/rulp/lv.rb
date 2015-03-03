##
# An LP Variable. Used as arguments in LP Expressions.
# The subtypes BV and IV represent Binary and Integer variables.
# These are constructed dynamically by using the special Capitalised variable declaration syntax.
##
class LV
  attr_reader :name
  attr_accessor :lt, :lte, :gt, :gte, :value
  include Rulp::Bounds
  include Rulp::Initializers

  def to_proc
    ->(index){ send(self.meth(index)) }
  end

  def meth(*args)
    "#{self.name}#{args.join("_")}_#{self.suffix}"
  end

  def suffix
    "f"
  end

  def self.method_missing(name, *args)
    return self.definition( "#{name}#{args.join("_")}" )
  end

  def self.const_missing(name)
    return self.definition(name)
  end

  def self.definition(name)
    self.class.send(:define_method, name){
      defined = LV::names_table["#{name}"]
      if defined && defined.class != self
        raise StandardError.new("ERROR:\n#{name} was already defined as a variable of type #{defined.class}."+
                                "You are trying to redefine it as a variable of type #{self}")
      elsif(!defined)
        self.new(name)
      else
        defined
      end
    }
    return self.send(name) || self.new(name)
  end

  def * (numeric)
    self.nocoerce
    Expressions.new([Fragment.new(self, numeric)])
  end

  def -@
    return self * -1
  end

  def -(other)
    self + (-other)
  end

  def + (expressions)
    Expressions[self] + Expressions[expressions]
  end

  def value
    return nil unless @value
    if self.class == BV
      return @value.round(2) == 1
    elsif self.class == IV
      return @value
    else
      @value
    end
  end

  def inspect
    "#{name}(#{suffix})[#{value || 'undefined'}]"
  end
end

class BV < LV;
  def suffix
    "b"
  end
end
class IV < LV;
  def suffix
    "i"
  end
end