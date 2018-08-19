# frozen_string_literal: true

require 'colorize'

RSpec.describe RubyFriendlyError do
  it 'has a version number' do
    expect(RubyFriendlyError::VERSION).to be '0.0.1'
  end

  describe '.exec' do
    subject { described_class.exec(code) }

    before { String.disable_colorization = true }

    context 'when not exist error' do
      let(:code) do
        <<~CODE
          player_life = 100
          print 'hoge' if player_life > 0
        CODE
      end

      it 'display message' do
        expect do
          subject
        end.to output('hoge').to_stdout_from_any_process
          .and not_output.to_stderr_from_any_process
          .and not_raise_error
      end
    end

    context "when exist 'missing_end'" do
      let(:code) do
        <<~CODE
          if gets.to_i == 1
            if gets.to_i == 2
              puts 'foobar'
            # missing `end`
          end
        CODE
      end
      let(:messages) do
        <<~MESSAGE
          4:   # missing `end`
          5: end
          6:

          syntax error:
            missing `end`.
            Probably the cause is more before line.
        MESSAGE
      end

      it 'display message' do
        expect do
          subject
        end.to output(messages).to_stderr_from_any_process
          .and raise_error Parser::SyntaxError
      end
    end

    context "when exist 'unnecessary_end'" do
      let(:code) do
        <<~CODE
          if gets.to_i == 1
            if gets.to_i == 2
              puts 'foobar'
            end
          end

          end # unnecessary `end`
        CODE
      end
      let(:messages) do
        <<~MESSAGE
          5: end
          6:
          7: end # unnecessary `end`

          syntax error:
            exist unnecessary `end`.
            Please remove unnecessary `end`.
        MESSAGE
      end

      it 'display message' do
        expect do
          subject
        end.to output(messages).to_stderr_from_any_process
          .and raise_error Parser::SyntaxError
      end
    end
  end
end
