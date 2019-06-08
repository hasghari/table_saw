# frozen_string_literal: true

require 'table_saw/manifest'

RSpec.describe TableSaw::Manifest do
  subject(:manifest) { described_class.new(config) }

  let(:config) do
    {
      'variables' => {
        'author_id' => 134
      },
      'tables' => [
        { 'table' => 'authors' },
        { 'table' => 'books', 'query' => 'select * from books where author_id = %{author_id}' }
      ]
    }
  end

  describe '#variables' do
    it 'returns correct values' do
      expect(manifest.variables).to eq 'author_id' => 134
    end
  end

  describe '#tables' do
    it 'returns correct size' do
      expect(manifest.tables.size).to eq 2
    end

    describe '#table' do
      it 'sets the name' do
        expect(manifest.tables.values.map(&:name)).to eq %w(authors books)
      end

      it 'returns correct query' do
        expect(manifest.tables.values.map(&:query)).to eq(['select id from authors',
                                                           'select * from books where author_id = 134'])
      end
    end
  end
end
