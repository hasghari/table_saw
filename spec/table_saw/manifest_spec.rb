# frozen_string_literal: true

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

  describe '#partial?' do
    context 'when query is provided' do
      it 'returns true' do
        expect(manifest.tables['books'].partial?).to be true
      end
    end

    context 'when query is not provided' do
      it 'returns false' do
        expect(manifest.tables['authors'].partial?).to be false
      end
    end
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

  describe '::instance' do
    before do
      TableSaw.configure(manifest: file)
    end

    context 'when manifest file does not exist' do
      let(:file) { 'foobar.yml' }

      it 'raises error' do
        expect { described_class.instance }.to raise_error ArgumentError
      end
    end

    context 'when manifest file does not exist' do
      let(:file) { 'spec/fixtures/manifest.yml' }

      it 'returns manifest instance' do
        expect(described_class.instance).to be_a described_class
      end
    end
  end
end
