# frozen_string_literal: true

RSpec.describe TableSaw::Formats::Insert do
  subject(:formatter) { described_class.new('authors') }

  describe '#header' do
    it 'returns prepared statement' do
      expect(formatter.header).to eq <<~SQL.squish
        PREPARE authors_insert_plan (bigint, character varying) AS INSERT INTO authors (id, name) VALUES ($1, $2);
      SQL
    end
  end

  describe '#footer' do
    it 'returns blank line' do
      expect(formatter.footer).to eq "\n"
    end
  end

  describe '#dump_row' do
    it 'returns execute statement' do
      expect(formatter.dump_row(['1', 'Dan Brown'])).to eq "EXECUTE authors_insert_plan(1, 'Dan Brown');"
    end
  end

  describe '#coder' do
    it 'returns row decoder' do
      expect(formatter.coder).to be_an_instance_of PG::TextDecoder::CopyRow
    end
  end
end
