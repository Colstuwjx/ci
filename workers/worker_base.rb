require_relative "../shared/logging_module"

module FastlaneCI
  # super class for all fastlane.ci workers
  # Subclass this class, and implement `work` and `timeout`
  class WorkerBase
    include FastlaneCI::Logging

    attr_accessor :should_stop

    def initialize
      self.should_stop = false
      Thread.new do
        until self.should_stop
          sleep(self.timeout)
          begin
            self.work unless self.should_stop
          rescue StandardError => ex
            puts("[#{self.class} Exception]: #{ex}: ")
            puts(ex.backtrace.join("\n"))
          end
        end
      end
    end

    def work
      not_implemented(__method__)
    end

    def provider_type
      not_implemented(__method__)
    end

    def die!
      logger.debug("Stopping worker")
      @should_stop = true
    end

    # Timeout in seconds
    def timeout
      not_implemented(__method__)
    end
  end
end