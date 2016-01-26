require 'spec_helper'

describe PureRubyMarshal do
  describe '.load' do
    FIXTURES.each do |fixture_name, fixture_value|
      it "loads marshalled #{fixture_name}" do
        result = PureRubyMarshal.load(Marshal.dump(fixture_value))
        expect(result).to eq(fixture_value)
      end
    end

    it 'loads marshalled extended object' do
      object = [].extend(MyModule)
      result = PureRubyMarshal.load(Marshal.dump(object))
      expect(result).to be_a(MyModule)
    end
  end

  describe '.dump' do
    FIXTURES.each do |fixture_name, fixture_value|
      it "writes marshalled #{fixture_name}" do
        marshalled = PureRubyMarshal.dump(fixture_value)
        loaded = Marshal.load(marshalled)
        expect(loaded).to eq(fixture_value)
      end
    end
  end
end
