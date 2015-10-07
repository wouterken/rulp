module Rulp
  module Initializers
    def initialize(name, args)
      @name = name
      @args = args
      @identifier = "#{self.name}#{self.args.join("_")}"
      raise StandardError.new("Variable with the name #{self} of a different type (#{LV::names_table[self.to_s].class}) already exists") if LV::names_table[self.to_s]
      LV::names_table[self.to_s] = self
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def names_table
        @@names ||= {}
      end

      def clear
        @@names = {}
      end
    end

    def to_s
      @identifier
    end
  end
end

