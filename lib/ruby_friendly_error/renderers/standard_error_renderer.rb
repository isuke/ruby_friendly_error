# frozen_string_literal: true

module RubyFriendlyError::Renderers
  class StandardErrorRenderer < ExceptionRenderer
  private

    def ast
      @ast ||= RubyFriendlyError::Utils.suppress_error_display { Parser::CurrentRuby.parse file_content }
    end

    def file_path
      @file_path ||= exception.backtrace.first.match(/(.+):[0-9]+:/)[1]
    end

    def file_content
      @file_content ||= eval? ? eval_file_content : File.read(file_path)
    end

    def error_line
      exception.backtrace.first.match(/:([0-9]+):/)[1].to_i
    end

    def exception_i18n_name
      I18n.t 'standard_error.name_error.title'
    end
  end
end
