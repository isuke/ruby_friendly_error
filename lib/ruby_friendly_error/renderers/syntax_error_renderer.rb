# frozen_string_literal: true

module RubyFriendlyError::Renderers
  class SyntaxErrorRenderer < ExceptionRenderer
  private

    def file_path
      @file_path ||= exception.message.match(/(.+):[0-9]+:/)[1]
    end

    def file_content
      @file_content ||= eval? ? eval_file_content : File.read(file_path)
    end

    def error_line_number
      exception.message.match(/:([0-9]+):/)[1].to_i
    end

    def exception_i18n_name
      I18n.t 'syntax_error.title'
    end
  end
end
