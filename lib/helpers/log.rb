require 'logger'

module Rulp
  module Log

    def print_solver_outputs=(print)
      @@print_solver_outputs = print
    end

    def print_solver_outputs
      @@print_solver_outputs
    end

    def log_level=(level)
      @@log_level = level
    end

    def log_level
      @@log_level || Logger::DEBUG
    end

    def log(level, message)
      if level >= self.log_level
        self.logger.add(level, message)
      end
    end

    def logger=(logger)
      @@logger = logger
    end

    def logger
      @@logger ||= Logger.new(STDOUT)
    end
  end
end