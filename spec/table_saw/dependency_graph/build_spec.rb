# frozen_string_literal: true

RSpec.describe TableSaw::DependencyGraph::Build do
  subject(:graph) { described_class.new(manifest) }

  let(:manifest) do
    TableSaw::Manifest.new(
      'tables' => [
        { 'table' => 'authors' },
        { 'table' => 'books' }
      ]
    )
  end

  context 'when no records exist' do
    context 'with full table' do
      it 'returns table' do
        expect(graph.call.keys).to match_array %w(authors books)
      end
    end

    context 'with partial table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'authors', 'query' => 'select * from authors' },
            { 'table' => 'books', 'query' => 'select * from books' }
          ]
        )
      end

      it 'returns empty records' do
        expect(graph.call).to eq({})
      end
    end
  end

  context 'when no foreign keys exist' do
    before do
      Author.create!(id: 1, name: 'Dan Brown')
    end

    context 'with full table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'authors' }
          ]
        )
      end

      it 'returns records for table' do
        expect(graph.call).to match('authors' => an_instance_of(TableSaw::DependencyGraph::DumpTable))
      end

      it 'has correct copy statement' do
        expect(graph.call['authors'].copy_statement).to eq 'select * from authors'
      end
    end

    context 'with partial table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'authors', 'query' => 'select id from authors where id = 1' }
          ]
        )
      end

      it 'returns records for table' do
        expect(graph.call).to match('authors' => an_instance_of(TableSaw::DependencyGraph::DumpTable))
      end

      it 'has correct copy statement' do
        expect(graph.call['authors'].copy_statement).to eq 'select * from authors where id in (1)'
      end
    end
  end

  context 'when foreign keys exist' do
    before do
      Author.create!(id: 1, name: 'Dan Brown')
      Book.create!(id: 1, author_id: 1, name: 'Angels & Demons')
    end

    context 'with full table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'books' }
          ]
        )
      end

      it 'fetches foreign key tables when not listed explicitly' do
        expect(graph.call.keys).to match_array %w(authors books)
      end
    end

    context 'with partial table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'books', 'query' => 'select id from books where id = 1' }
          ]
        )
      end

      it 'fetches records for original table' do
        expect(graph.call['books'].ids).to eq Set.new(['1'])
      end

      it 'fetches records for foreign keys when not listed explicitly' do
        expect(graph.call['authors'].ids).to eq Set.new(['1'])
      end
    end
  end

  context 'when has_many whitelisted' do
    before do
      Author.create!(id: 1, name: 'Dan Brown')
      Book.create!(id: 1, author_id: 1, name: 'Angels & Demons')
      Chapter.create!(id: 1, book_id: 1)
      Chapter.create!(id: 2, book_id: 1)
    end

    context 'with full table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'books', 'has_many' => ['chapters'] }
          ]
        )
      end

      it 'fetches associated has_many' do
        expect(graph.call.keys).to match_array %w(authors books chapters)
      end

      it 'has full dump tables for all' do
        expect(graph.call.values).to all(have_attributes(partial: false))
      end
    end

    context 'with partial table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'books', 'query' => 'select id from books where id = 1', 'has_many' => ['chapters'] }
          ]
        )
      end

      it 'fetches associated has_many' do
        expect(graph.call['chapters'].ids).to eq Set.new(%w(1 2))
      end
    end
  end
end
