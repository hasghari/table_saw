# frozen_string_literal: true

RSpec.describe TableSaw::Formats::Base do
  subject(:formatter) { described_class.new('foobar') }

  describe '#header' do
    it 'raises error' do
      expect { formatter.header }.to raise_error NotImplementedError
    end
  end

  describe '#footer' do
    it 'raises error' do
      expect { formatter.footer }.to raise_error NotImplementedError
    end
  end

  describe '#dump_row' do
    it 'raises error' do
      expect { formatter.dump_row(nil) }.to raise_error NotImplementedError
    end
  end

  describe '#coder' do
    it 'returns nil' do
      expect(formatter.coder).to be_nil
    end
  end
end
