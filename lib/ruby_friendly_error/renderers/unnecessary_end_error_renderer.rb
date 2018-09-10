# frozen_string_literal: true

module RubyFriendlyError::Renderers
  class UnnecessaryEndErrorRenderer < SyntaxErrorRenderer
  private

    def error_message
      I18n.t('syntax_error.unnecessary_end')
    end

    def display_error_detail
      display_error_line
    end
  end
end
