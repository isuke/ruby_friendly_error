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

      def replace_string_at string, range
        regexp          = Regexp.new "\\A(.{#{range.first - 1}})(.{#{range.size}})(.*)\\Z"
        match_data      = string.match regexp
        replaced_string = yield match_data[2]
        match_data[1] + replaced_string + match_data[3]
      end
    end
  end
end
