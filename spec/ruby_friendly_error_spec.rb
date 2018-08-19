# frozen_string_literal: true

require 'colorize'

RSpec.describe RubyFriendlyError do
  it 'has a version number' do
    expect(RubyFriendlyError::VERSION).to be '0.0.1'
  end

  describe '.exec' do
    before { String.disable_colorization = true }

    context "when exist 'missing_end'" do
      subject { described_class.exec(code) }

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
        expect { subject }.to output(messages).to_stderr_from_any_process
      end
    end
  end
end
