# frozen_string_literal: true

require 'colorize'
require 'i18n'
require 'parser/current'
require 'pry'

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
      exec File.read(file_path)
    end

    def exec file_content
      suppress_error_display { _ast = Parser::CurrentRuby.parse file_content }

      Kernel.load file_path
    rescue Parser::SyntaxError => ex
      case ex.message
        when 'unexpected token $end'
          render_missing_end_error file_content, ex
      end
    end

    def render_missing_end_error file_content, ex
      line = ex.diagnostic.location.line
      display_error_line file_content, line
      STDERR.puts I18n.t('syntax_error.title').colorize(:light_red) + ':'
      STDERR.puts format_lines(I18n.t('syntax_error.missing_end')) { |l, _i| "  #{l}" }.colorize(:light_red)
    end

    def render_unnecessary_end_error file_content, ex
      line = ex.diagnostic.location.line
      display_error_line file_content, line
      STDERR.puts I18n.t('syntax_error.title').colorize(:light_red) + ':'
      STDERR.puts format_lines(I18n.t('syntax_error.unnecessary_end')) { |l, _i| "  #{l}" }.colorize(:light_red)
    end

  private

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
      window_end   = [error_line - window + 1, line_size + 1].min

      STDERR.puts format_lines(lines, window_start  , error_line - 1) { |l, i| "#{error_line - window + i}: #{l}" }&.colorize(:light_yellow)
      STDERR.puts format_lines(lines, error_line    , error_line) { |l, i| "#{error_line + i}: #{l}" }&.colorize(:light_red)
      STDERR.puts format_lines(lines, error_line + 1, window_end) { |l, i| "#{error_line + window + i}: #{l}" }&.colorize(:light_yellow)
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
