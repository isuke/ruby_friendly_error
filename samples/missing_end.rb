# frozen_string_literal: true

# 10:   # missing end
# 11: end
# 12:

# syntax error:
#   missing `end`.
#   Probably the cause is more before line.

if gets.to_i == 1
  if gets.to_i == 2
    puts 'foobar'
  # missing `end`
end
