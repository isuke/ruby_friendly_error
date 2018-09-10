# frozen_string_literal: true

module RubyFriendlyError
  class Utils
    class << self
      def suppress_error_display
        original_stdout = $stderr
        $stderr         = StringIO.new

        yield
      ensure
        $stderr = original_stdout
      end
    end
  end
end
