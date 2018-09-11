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
        node_location = ast.find_by_variable_name(var_name).location
        display_error_line_string node_location.line, strong_pos_range: ((node_location.column + 1)..node_location.last_column)
      end

      display_error_line_string strong_pos_range: ((error_node.location.column + 1)..error_node.location.last_column)
    end
  end
end
