# frozen_string_literal: true

require 'colorize'
require 'i18n'
require 'parser/current'

require 'ruby_friendly_error/ast'
require 'ruby_friendly_error/utils'
require 'ruby_friendly_error/version'

require 'ruby_friendly_error/renderers/exception_renderer'
require 'ruby_friendly_error/renderers/syntax_error_renderer'
require 'ruby_friendly_error/renderers/missing_end_error_renderer'
require 'ruby_friendly_error/renderers/unnecessary_end_error_renderer'
require 'ruby_friendly_error/renderers/standard_error_renderer'
require 'ruby_friendly_error/renderers/name_error_renderer'
require 'ruby_friendly_error/renderers/argument_error_renderer'

Bundler.require(:development)

Parser::Builders::Default.emit_lambda   = true
Parser::Builders::Default.emit_procarg0 = true
Parser::Builders::Default.emit_encoding = true
Parser::Builders::Default.emit_index    = true

module RubyFriendlyError
  module Renderers; end

  ROOT_PATH     = Pathname.new(__FILE__).dirname.parent.to_s
  WINDOW        = 2
  DISPLAY_START = '<' * 80
  DISPLAY_END   = '>' * 80

  I18n.load_path = Dir[File.join(ROOT_PATH, 'locales', '*.yml')]
  I18n.backend.load_translations

  class << self
    def load file_path, lang = :en
      exec File.read(file_path), File.expand_path(file_path), lang
    end

    def exec file_content, file_name = '(eval)', lang = :en
      load_i18n lang

      eval file_content, nil, file_name, 1 # rubocop:disable Security/Eval
    rescue Exception => exception # rubocop:disable Lint/RescueException
      renderer_class = renderer_class(exception)

      raise exception unless renderer_class

      renderer_class.new(exception, file_content).render
      exit false
    end

  private

    def load_i18n lang
      I18n.backend.store_translations(lang, YAML.load_file(File.join(ROOT_PATH, 'locales', "#{lang}.yml")))
      I18n.locale = lang
    end

    def renderer_class exception
      case exception
        when SyntaxError
          case exception.message
            when /unnecessary `end`/
              RubyFriendlyError::Renderers::UnnecessaryEndErrorRenderer
            when /unexpected end-of-input/
              RubyFriendlyError::Renderers::MissingEndErrorRenderer
          end
        when NameError
          RubyFriendlyError::Renderers::NameEndErrorRenderer
        when ArgumentError
          RubyFriendlyError::Renderers::ArgumentErrorRenderer
      end
    end
  end
end
