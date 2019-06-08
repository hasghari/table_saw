# frozen_string_literal: true

require 'table_saw/build_dependency_graph'
require 'table_saw/manifest'

RSpec.describe TableSaw::BuildDependencyGraph do
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
    it 'returns empty records' do
      expect(graph.call).to eq({})
    end
  end

  context 'when no foreign keys exist' do
    before do
      Author.create!(id: 1, name: 'Dan Brown')
    end

    it 'returns records for table' do
      expect(graph.call['authors'].to_a).to eq ['1']
    end
  end

  context 'when foreign keys exist' do
    let(:manifest) do
      TableSaw::Manifest.new(
        'tables' => [
          { 'table' => 'books' }
        ]
      )
    end

    before do
      Author.create!(id: 1, name: 'Dan Brown')
      Book.create!(id: 1, author_id: 1, name: 'Angels & Demons')
    end

    it 'fetches foreign keys when not listed explicitly' do
      expect(graph.call).to eq('authors' => Set.new(['1']), 'books' => Set.new(['1']))
    end
  end

  context 'when has_many whitelisted' do
    let(:manifest) do
      TableSaw::Manifest.new(
        'tables' => [
          { 'table' => 'books', 'has_many' => ['chapters'] }
        ]
      )
    end

    before do
      Author.create!(id: 1, name: 'Dan Brown')
      Book.create!(id: 1, author_id: 1, name: 'Angels & Demons')
      Chapter.create!(id: 1, book_id: 1)
      Chapter.create!(id: 2, book_id: 1)
    end

    it 'fetches associated has_many' do
      expect(graph.call).to eq('authors' => Set.new(['1']), 'books' => Set.new(['1']), 'chapters' => Set.new(%w(1 2)))
    end
  end
end
