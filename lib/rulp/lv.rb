# frozen_string_literal: true

##
# An LP Variable. Used as arguments in LP Expressions.
# The subtypes BV and IV represent Binary and Integer variables.
# These are constructed dynamically by using the special Capitalised variable declaration syntax.
##
class LV
  attr_reader :name, :args
  attr_writer :value
  attr_accessor :lt, :lte, :gt, :gte

  include Rulp::Bounds
  include Rulp::Initializers

  def to_proc
    ->(index){ send(self.meth, index) }
  end

  def meth
    "#{self.name}_#{self.suffix}"
  end

  def self.suffix
    ENV['RULP_LV_SUFFIX'] || "f"
  end

  def suffix
    self.class.suffix
  end

  def self.definition(name, *args)
    identifier = "#{name}#{args.join("_")}"
    defined = LV::names_table["#{identifier}"]
    case defined
    when self then defined
    when nil then self.new(name, args)
    else raise StandardError.new("ERROR:\n#{name} was already defined as a variable of type #{defined.class}."+
                              "You are trying to redefine it as a variable of type #{self}")
    end
  end

  def *(numeric)
    self.nocoerce
    Expressions.new([Fragment.new(self, numeric)])
  end

  def -@
    return self * -1
  end

  def -(other)
    self + (-other)
  end

  def +(expressions)
    Expressions[self] + Expressions[expressions]
  end

  def value
    return nil unless @value
    case self
    when BV then @value.round(2) == 1
    when IV then @value
    else @value
    end
  end

  def value?
    value ? value : false
  end

  def inspect
    "#{name}#{args.join("-")}(#{suffix})[#{value.nil? ? 'undefined' : value }]"
  end

  alias_method :selected?, :value?
end

class BV < LV;
  def self.suffix
    ENV['RULP_BV_SUFFIX'] || "b"
  end
end

class IV < LV;
  def self.suffix
    ENV['RULP_IV_SUFFIX'] || "i"
  end
end
