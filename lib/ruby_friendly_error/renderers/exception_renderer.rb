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

    def error_line
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
      STDERR.puts "#{exception_i18n_name.underline} #{I18n.t('main_message')}: #{file_path}:#{error_line}".colorize(:light_red)
      STDERR.puts
    end

    def display_error_detail
      raise NotImplementedError, "You must implement #{__method__}"
    end

    def display_message
      STDERR.puts "#{exception_i18n_name.underline}:".colorize(:light_red)
      STDERR.puts format_lines(error_message) { |l, _i| "  #{l}" }.colorize(:light_red)
    end

    def display_error_line line = error_line, window = RubyFriendlyError::WINDOW
      lines        = file_content.split("\n", -1)
      line_size    = lines.size
      window_start = [line - window, 1].max
      window_end   = [line + window, line_size].min

      if line > 1
        start_line = window_start
        end_line   = line - 1
        STDERR.puts format_lines(lines, start_line, end_line) { |l, i| "#{start_line + i}: #{l}" }&.colorize(:light_yellow)
      end
      STDERR.puts "#{line}: #{lines[line - 1]}".rstrip.colorize(:light_red)
      if line < line_size
        start_line = line + 1
        end_line   = window_end
        STDERR.puts format_lines(lines, line + 1, end_line) { |l, i| "#{start_line + i}: #{l}" }&.colorize(:light_yellow)
      end
      STDERR.puts
    end

    def format_lines lines, start_line = 1, end_line = 0
      lines =
        case lines
          when String then lines.split("\n", -1)
          when Array  then lines
        end
      lines[(start_line - 1)..(end_line - 1)]
        &.map
        &.with_index { |l, i| block_given? ? yield(l, i).rstrip : l.rstrip }
        &.join("\n")
    end
  end
end
