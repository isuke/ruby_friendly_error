# frozen_string_literal: true

module RubyFriendlyError::Renderers
  class NameEndErrorRenderer < StandardErrorRenderer
  private

    def corrections
      @corrections ||= exception.spell_checker.corrections
    end

    def error_message
      var_name_str    = exception.spell_checker.name.underline
      corrections_str = corrections.map { |c| "`#{c.to_s.underline}`" }.join(', ')
      I18n.t('standard_error.name_error.with_did_you_mean', var_name: var_name_str, corrections: corrections_str)
    end

    def display_error_detail
      corrections.each do |var_name|
        node = ast.find_by_variable_name var_name
        display_error_line node.location.line
      end

      display_error_line
    end
  end
end
