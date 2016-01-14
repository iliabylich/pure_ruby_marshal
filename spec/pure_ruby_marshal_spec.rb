require 'spec_helper'

describe PureRubyMarshal do
  describe '.load' do
    FIXTURES.each do |fixture_name, fixture_value|
      it "loads marshalled #{fixture_name}" do
        result = PureRubyMarshal.load(Marshal.dump(fixture_value))
        expect(result).to eq(fixture_value)
      end
    end
  end
end
