# frozen_string_literal: true

RSpec.describe TableSaw::Queries::ForeignKeyRelationships do
  subject(:query) { described_class.new }

  describe '#belongs_to' do
    it 'returns a hash of belongs_to associations' do
      expect(query.belongs_to).to eq('books' => { 'author_id' => 'authors' }, 'chapters' => { 'book_id' => 'books' })
    end
  end

  describe '#has_many' do
    it 'returns a hash of has_many associations' do
      expect(query.has_many).to eq('authors' => [%w(books author_id)], 'books' => [%w(chapters book_id)])
    end
  end
end
