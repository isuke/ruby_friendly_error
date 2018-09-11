# frozen_string_literal: true

module RubyFriendlyError::Renderers
  class ExceptionRenderer
    attr_reader :exception
    attr_reader :eval_file_content

    def initialize exception, eval_file_content
      @exception         = exception
      @eval_file_content = eval_file_content
    end

    def render
      display_backtrace exception.backtrace unless eval?

      display_main_message

      display_error_detail

      display_message
    end

  private

    def file_name
      @file_name ||= File.basename(file_path)
    end

    def file_path
      raise NotImplementedError, "You must implement #{__method__}"
    end

    def file_expand_path
      @file_expand_path ||= File.expand_path(file_path)
    end

    def file_content
      raise NotImplementedError, "You must implement #{__method__}"
    end

    def eval?
      file_name == '(eval)'
    end

    def exception_i18n_name
      raise NotImplementedError, "You must implement #{__method__}"
    end

    def error_line_number
      raise NotImplementedError, "You must implement #{__method__}"
    end

    def error_message
      raise NotImplementedError, "You must implement #{__method__}"
    end

    def display_backtrace backtrace
      fake_backtrace = backtrace
        .dup
        .delete_if { |b| b.match(/ruby_friendly_error/) }
        .delete_if { |b| b.match(/`block in exec'/) }
        .map do |b|
          if b.match? Regexp.new("#{@file_name}.*`exec'")
            b.sub("`exec'", "`<main>'")
          else
            b
          end
        end

      fake_backtrace_size   = fake_backtrace.size
      fake_backtrace_digits = fake_backtrace_size.to_s.length

      fake_backtrace.reverse_each.with_index do |b, i|
        num        = fake_backtrace_size - i
        num_digits = num.to_s.length
        color      = b.include?(@file_name) ? :light_red : :light_yellow
        STDERR.puts "#{' ' * (fake_backtrace_digits - num_digits)}#{num}: #{b}".colorize(color)
      end
      STDERR.puts
    end

    def display_main_message
      STDERR.puts "#{exception_i18n_name.underline} #{I18n.t('main_message')}: #{file_path}:#{error_line_number}".colorize(:light_red)
      STDERR.puts
    end

    def display_error_detail
      raise NotImplementedError, "You must implement #{__method__}"
    end

    def display_message
      STDERR.puts "#{exception_i18n_name.underline}:".colorize(:light_red)
      STDERR.puts format_line_strings(error_message) { |l, _i| "  #{l}" }.colorize(:light_red)
    end

    def display_error_line_string line_number = error_line_number, strong_pos_range: nil, window: RubyFriendlyError::WINDOW
      line_strings   = file_content.split("\n", -1)
      file_line_size = line_strings.size
      window_start   = [line_number - window, 1].max
      window_end     = [line_number + window, file_line_size].min

      STDERR.puts RubyFriendlyError::DISPLAY_START.colorize(:light_yellow)

      display_error_line_string_window line_strings, window_start, line_number - 1 if line_number > 1

      lint_string =
        if strong_pos_range
          RubyFriendlyError::Utils.replace_string_at(line_strings[line_number - 1], strong_pos_range, &:underline)
        else
          line_strings[line_number - 1]
        end
      STDERR.puts "#{line_number}: #{lint_string}".rstrip.colorize(:light_red)

      display_error_line_string_window line_strings, line_number + 1, window_end if line_number < file_line_size

      STDERR.puts RubyFriendlyError::DISPLAY_END.colorize(:light_yellow)
      STDERR.puts
    end

    def display_error_line_string_window line_strings, start_line_number, end_line_number
      STDERR.puts format_line_strings(line_strings, start_line_number, end_line_number) { |l, i| "#{start_line_number + i}: #{l}" }&.colorize(:light_yellow)
    end

    def format_line_strings line_strings, start_line = 1, end_line = 0
      line_strings =
        case line_strings
          when String then line_strings.split("\n", -1)
          when Array  then line_strings
        end
      line_strings[(start_line - 1)..(end_line - 1)]
        &.map
        &.with_index { |l, i| block_given? ? yield(l, i).rstrip : l.rstrip }
        &.join("\n")
    end
  end
end
