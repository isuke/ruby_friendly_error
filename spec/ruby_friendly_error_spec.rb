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
          8:

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

    context "when exist 'miss spell variable'" do
      let(:code) do
        <<~CODE
          prayer_life = 100
          player_lifee = 200

          puts 'hoge' if player_life > 0
        CODE
      end
      let(:messages) do
        <<~MESSAGE
          1: prayer_life = 100
          2: player_lifee = 200
          3:
          4: puts 'hoge' if player_life > 0

          1: prayer_life = 100
          2: player_lifee = 200
          3:

          name error:
            undefined local variable or method `player_life`
            Did you mean? `player_lifee`, `prayer_life`
        MESSAGE
      end

      it 'display message' do
        expect do
          subject
        end.to output(messages).to_stderr_from_any_process
          .and raise_error NameError
      end
    end

    context "when exist 'miss spell arg'" do
      let(:code) do
        <<~CODE
          def hoge prayer_life = 100 , player_lifee = 100
            puts 'hoge' if player_life > 0
          end

          hoge
        CODE
      end
      let(:messages) do
        <<~MESSAGE
          1: def hoge prayer_life = 100 , player_lifee = 100
          2:   puts 'hoge' if player_life > 0
          3: end

          1: def hoge prayer_life = 100 , player_lifee = 100
          2:   puts 'hoge' if player_life > 0
          3: end

          name error:
            undefined local variable or method `player_life`
            Did you mean? `player_lifee`, `prayer_life`
        MESSAGE
      end

      it 'display message' do
        expect do
          subject
        end.to output(messages).to_stderr_from_any_process
          .and raise_error NameError
      end
    end
  end
end
