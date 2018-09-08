# frozen_string_literal: true

require 'colorize'
require 'i18n'
require 'parser/current'
require 'pry'

require 'ruby_friendly_error/ast'
require 'ruby_friendly_error/version'

Parser::Builders::Default.emit_lambda   = true
Parser::Builders::Default.emit_procarg0 = true
Parser::Builders::Default.emit_encoding = true
Parser::Builders::Default.emit_index    = true

module RubyFriendlyError
  ROOT_PATH = Dir.pwd
  WINDOW    = 2

  I18n.load_path = Dir[File.join(ROOT_PATH, 'locales', '*.yml')]
  I18n.backend.load_translations
  I18n.backend.store_translations(:en , YAML.load_file(File.join(ROOT_PATH, 'locales', 'en.yml')))

  class << self
    def load file_path
      exec File.read(file_path), file_path
    end

    def exec file_content, file_name = '(eval)'
      eval file_content, nil, file_name # rubocop:disable Security/Eval
    rescue Exception => ex # rubocop:disable Lint/RescueException
      exception_file_name    = file_name == '(eval)' ? file_name : ex.backtrace.first.match(/(.+):[0-9]+:/)[1]
      exception_file_content = file_name == '(eval)' ? file_content : File.read(exception_file_name)
      exception_handling ex, exception_file_name, exception_file_content, file_name != '(eval)'
    end

  private

    def exception_handling exception, file_name, file_content, displayed_backtrace
      display_backtrace file_name, exception.backtrace if displayed_backtrace

      case exception
        when SyntaxError
          case exception.message
            when /unnecessary `end`/
              render_unnecessary_end_error file_content, exception
            when /unexpected end-of-input/
              render_missing_end_error file_content, exception
          end
        when NameError
          ast = suppress_error_display { Parser::CurrentRuby.parse file_content }
          render_name_error_with_did_you_mean file_content, exception, ast
      end

      raise exception
    end

    def render_missing_end_error file_content, ex
      line = ex.message.match(/:([0-9]+):/)[1].to_i
      display_error_line file_content, line
      STDERR.puts I18n.t('syntax_error.title').colorize(:light_red) + ':'
      STDERR.puts format_lines(I18n.t('syntax_error.missing_end')) { |l, _i| "  #{l}" }.colorize(:light_red)
    end

    def render_unnecessary_end_error file_content, ex
      line = ex.message.match(/:([0-9]+):/)[1].to_i
      display_error_line file_content, line
      STDERR.puts I18n.t('syntax_error.title').colorize(:light_red) + ':'
      STDERR.puts format_lines(I18n.t('syntax_error.unnecessary_end')) { |l, _i| "  #{l}" }.colorize(:light_red)
    end

    def render_name_error_with_did_you_mean file_content, ex, ast
      corrections = ex.spell_checker.corrections
      corrections.each do |var_name|
        node = ast.find_by_variable_name var_name
        display_error_line file_content, node.loc.line
      end

      STDERR.puts I18n.t('name_error.title').colorize(:light_red) + ':'
      var_name_str    = ex.spell_checker.name.underline
      corrections_str = corrections.map { |c| "`#{c.to_s.underline}`" }.join(', ')
      message         = I18n.t('name_error.with_did_you_mean', var_name: var_name_str, corrections: corrections_str)
      STDERR.puts format_lines(message) { |l, _i| "  #{l}" }.colorize(:light_red)
    end

    def suppress_error_display
      original_stdout = $stderr
      $stderr         = StringIO.new

      yield
    ensure
      $stderr = original_stdout
    end

    def display_error_line file_content, error_line, window = WINDOW
      lines        = file_content.split("\n", -1)
      line_size    = lines.size
      window_start = [error_line - window, 1].max
      window_end   = [error_line + window, line_size].min

      if error_line > 1
        start_line = window_start
        end_line   = error_line - 1
        STDERR.puts format_lines(lines, start_line, end_line) { |l, i| "#{start_line + i}: #{l}" }&.colorize(:light_yellow)
      end
      STDERR.puts "#{error_line}: #{lines[error_line - 1]}".rstrip.colorize(:light_red)
      if error_line < line_size
        start_line = error_line + 1
        end_line   = window_end
        STDERR.puts format_lines(lines, error_line + 1, end_line) { |l, i| "#{start_line + i}: #{l}" }&.colorize(:light_yellow)
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

    def display_backtrace file_name, backtrace
      fake_backtrace = backtrace
        .dup
        .delete_if { |b| b.match(/ruby_friendly_error/) }
        .delete_if { |b| b.match(/`block in exec'/) }
        .map do |b|
          if b.match? Regexp.new("#{file_name}.*`exec'")
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
        STDERR.puts "#{' ' * (fake_backtrace_digits - num_digits)}#{num}:#{b}".colorize(:light_red)
      end
      STDERR.puts
    end
  end
end
