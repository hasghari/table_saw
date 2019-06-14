# frozen_string_literal: true

RSpec.describe TableSaw::Queries::TableColumns do
  subject(:query) { described_class.new(table) }

  context 'with authors table' do
    let(:table) { 'authors' }

    it 'returns columns in order' do
      expect(query.call).to eq %w(id name)
    end
  end

  context 'with books table' do
    let(:table) { 'books' }

    it 'returns columns in order' do
      expect(query.call).to eq %w(id author_id name)
    end
  end

  context 'with chapters table' do
    let(:table) { 'chapters' }

    it 'returns columns in order' do
      expect(query.call).to eq %w(id book_id title content)
    end
  end
end
