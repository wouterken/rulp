module Rulp
  module Bounds

    attr_accessor :const

    DIRS = {">" => {value: "gt=", equality: "gte="}, "<" => {value: "lt=", equality: "lte="}}
    DIRS_REVERSED = {">" => DIRS["<"], "<" => DIRS[">"]}

    def relative_constraint direction, value, equality=false
      direction = coerced? ? DIRS_REVERSED[direction] : DIRS[direction]
      self.const = false
      self.send(direction[:value], value)
      self.send(direction[:equality], equality)
      return self
    end

    def nocoerce
      @@coerced = false
    end

    def coerced?
      was_coerced = @@coerced rescue nil
      @@coerced = false
      return was_coerced
    end

    def >(val)
      relative_constraint(">", val)
    end

    def >=(val)
      relative_constraint(">", val, true)
    end

    def <(val)
      relative_constraint("<", val)
    end

    def <=(val)
      relative_constraint("<", val, true)
    end

    def ==(val)
      self.const = val
    end

    def coerce(something)
      @@coerced = true
      return self, something
    end

    def bounds_str
      return nil if !(self.gt || self.lt || self.const)
      return "#{self.name} = #{self.const}" if self.const

      [
        self.gt,
        self.gt ? "<=" : nil,
        self.name,
        self.lt ? "<=" : nil,
        self.lt
      ].compact.join(" ")
    end
  end
end