module Rulp
  module Initializers
    def initialize(name)
      raise Exception.new("Variable with the name #{name} of a different type (#{LV::names_table[name].class}) already exists") if LV::names_table[name]
      LV::names_table["#{name}#{self.class}"] = self
      @name = name
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def names_table
        @@names ||= {}
      end
    end

    def to_s
      "#{self.name}"
    end
  end
end

