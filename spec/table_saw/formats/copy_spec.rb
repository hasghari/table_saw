# frozen_string_literal: true

RSpec.describe TableSaw::Formats::Copy do
  subject(:formatter) { described_class.new('authors') }

  describe '#header' do
    it 'returns copy statement' do
      expect(formatter.header).to eq <<~SQL.squish
        COPY authors ("id", "name") FROM STDIN;
      SQL
    end
  end

  describe '#footer' do
    it 'returns terminating lines' do
      expect(formatter.footer).to eq ['\.', "\n"]
    end
  end

  describe '#dump_row' do
    it 'returns execute statement' do
      expect(formatter.dump_row("1\tDan Brown")).to eq "1\tDan Brown"
    end
  end

  describe '#coder' do
    it 'returns nil' do
      expect(formatter.coder).to be_nil
    end
  end
end
