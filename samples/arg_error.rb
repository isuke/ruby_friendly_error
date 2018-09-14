# frozen_string_literal: true

def hoge arg1, arg2 = 'foobar'
  puts arg1
  puts arg2
end

hoge 'piyo', 'fuga', 'what!?'
