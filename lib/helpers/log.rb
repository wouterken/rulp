##
# Basic logger module.
# Allows logging in the format
#
# "This is a string".log(:debug)
# "Oh no!".log(:error)
#
# Log level is set as follows.
# Rulp::Logger::level = :debug
#
##
module Rulp
  module Logger
    DEBUG = 5
    INFO  = 4
    WARN  = 3
    ERROR = 2
    OFF   = 1

    LEVELS = {
      debug: DEBUG,
      info: INFO,
      warn: WARN,
      error: ERROR,
      off: OFF
    }

    def self.level=(value)
      raise Exception.new("#{value} is not a valid log level") unless LEVELS[value]
      @@level = value
    end

    def self.level
      @@level || :info
    end

    def self.log(level, message)
      if(LEVELS[level].to_i <= LEVELS[self.level])
        puts("[#{level}] #{message}")
      end
    end

    self.level = :info

    class ::String
      def log(level)
        Logger::log(level, self)
      end
    end

    class ::Array
      def log(level, sep="\n")
        Logger::log(level, self.join("#{sep}[#{level}] "))
      end
    end
  end
end