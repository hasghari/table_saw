# frozen_string_literal: true

RSpec.describe TableSaw::Queries::SerialSequences do
  subject(:query) { described_class.new }

  describe '#call' do
    it 'does not have an entry for schema_migrations' do
      expect(query.call['schema_migrations']).to be_nil
    end

    it 'has an entry for authors' do
      expect(query.call['authors']).to have_attributes(name: 'public.authors_id_seq', table: 'authors', column: 'id')
    end

    it 'has an entry for books' do
      expect(query.call['books']).to have_attributes(name: 'public.books_id_seq', table: 'books', column: 'id')
    end

    it 'has an entry for chapters' do
      expect(query.call['chapters']).to have_attributes(name: 'public.chapters_id_seq', table: 'chapters', column: 'id')
    end
  end
end
