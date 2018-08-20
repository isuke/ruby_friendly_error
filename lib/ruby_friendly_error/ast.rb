# frozen_string_literal: true

require 'parser/current' unless defined? Parser::AST::Node

class Parser::AST::Node
  CLASS_VARIABLE_ASSIGNED_TYPE    = :cvasgn
  CLASS_VARIABLE_TYPE             = :cvar
  INSTANCE_VARIABLE_ASSIGNED_TYPE = :ivasgn
  INSTANCE_VARIABLE_TYPE          = :ivar
  LOCAL_VARIABLE_ASSIGNED_TYPE    = :lvasgn

  VARIABLE_TYPES = [
    CLASS_VARIABLE_ASSIGNED_TYPE,
    CLASS_VARIABLE_TYPE,
    INSTANCE_VARIABLE_ASSIGNED_TYPE,
    INSTANCE_VARIABLE_TYPE,
    LOCAL_VARIABLE_ASSIGNED_TYPE,
  ].freeze

  ARG_TYPE                = :arg
  OPTION_ARG_TYPE         = :optarg
  REST_ARG_TYPE           = :restarg
  BLOCK_ARG_TYPE          = :blockarg
  KEYWORD_ARG_TYPE        = :kwarg
  KEYWORD_ARG_OPTION_TYPE = :kwoptarg
  KEYWORD_REST_ARG_TYPE   = :kwrestarg

  ARG_TYPES = [
    ARG_TYPE,
    OPTION_ARG_TYPE,
    REST_ARG_TYPE,
    BLOCK_ARG_TYPE,
    KEYWORD_ARG_TYPE,
    KEYWORD_ARG_OPTION_TYPE,
    KEYWORD_REST_ARG_TYPE,
  ].freeze

  def find_by_variable_name variable_name
    to_a.each do |node|
      next unless node.is_a? Parser::AST::Node
      if VARIABLE_TYPES.include?(node.type) || ARG_TYPES.include?(node.type)
        return node if node.to_a[0].to_s.sub(/^@*/, '') == variable_name.to_s
      end

      result = node.find_by_variable_name(variable_name)
      return result if result
    end
    nil
  end
end
