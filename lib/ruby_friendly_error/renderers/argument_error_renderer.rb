# frozen_string_literal: true

module RubyFriendlyError::Renderers
  class ArgumentErrorRenderer < StandardErrorRenderer
  private

    def exception_i18n_name
      I18n.t 'standard_error.argument_error.title'
    end

    def def_node
      @def_node ||= ast.find_by_line_number error_line_number
    end

    def def_name
      @def_name ||= def_node.to_a[0]
    end

    def send_node
      @send_node ||= ast.find_send_by_def_name def_name
    end

    def error_message
      args_num_range = def_node.def_args_num_range

      args_num_str = args_num_range.size == 1 ? args_num_range.first.to_s : args_num_range.to_s

      I18n.t 'standard_error.argument_error.wrong_number_of_arguments', def_name: def_name, arg_range: args_num_str, send_arg: send_node.send_args_num
    end

    def display_error_detail
      display_error_line_string def_node.location.line, strong_pos_range: ((def_node.location.column + 1)..def_node.to_a[1].location.last_column)

      display_error_line_string send_node.location.line, strong_pos_range: ((send_node.location.column + 1)..send_node.location.last_column)
    end
  end
end
