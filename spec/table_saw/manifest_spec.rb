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

  describe '#variables with overrides' do
    around do |example|
      variables = TableSaw.configuration.variables
      TableSaw.configure { |c| c.variables = { 'author_id' => 42 } }
      example.run
      TableSaw.configure { |c| c.variables = variables }
    end

    it 'overrides the manifest variable' do
      expect(manifest.variables).to eq 'author_id' => 42
    end
  end

  describe '#variables with interpolation' do
    let(:config) do
      {
        'variables' => {
          'author_id' => author_id,
          'illustrator_id' => '%{author_id}'
        },
        'tables' => [
          { 'table' => 'authors' },
          { 'table' => 'books', 'query' => 'select * from books where author_id = %{illustrator_id}' }
        ]
      }
    end
    let(:author_id) { 134 }

    it 'interpolates previous variables into following variables' do
      expect(manifest.variables[:illustrator_id]).to eq manifest.variables[:author_id]
      expect(manifest.variables[:illustrator_id]).to_not eq '%{illustrator_id}'
    end

    context 'when attempting to interpolate another variable before it is declared' do
      let(:author_id) { '%{illustrator_id}' }

      it 'does not interpolate following variables into the initial variables' do
        expect(manifest.variables[:author_id]).to be_nil
      end
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
        expect(manifest.tables.values.map(&:query)).to eq([nil, 'select * from books where author_id = 134'])
      end

      context 'when the table query uses interpolated variables' do
        let(:config) do
          {
            'variables' => {
              'author_id' => '1,3,4',
              'book_ids' => 'select * from books where author_id in (%{author_id})'
            },
            'tables' => [
              { 'table' => 'authors' },
              { 'table' => 'books', 'query' => 'select * from books where book_id in (%{book_ids})' }
            ]
          }
        end

          it 'returns the correct query' do
            composed_query = 'select * from books where book_id in (select * from books where author_id in (1,3,4))'
            expect(manifest.tables.values.map(&:query)).to eq([nil, composed_query])
          end
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

    context 'when manifest file exists' do
      let(:file) { 'spec/fixtures/manifest.yml' }

      it 'returns manifest instance' do
        expect(described_class.instance).to be_a described_class
      end
    end
  end
end
