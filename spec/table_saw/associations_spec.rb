# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TableSaw::Associations do
  subject(:associations) { described_class.new(manifest) }

  let(:manifest) do
    TableSaw::Manifest.new(
      'foreign_keys' => [
        {
          'from_table' => 'slugs',
          'from_column' => 'sluggable_id:sluggable_type(Book)',
          'to_table' => 'books',
          'to_column' => 'id'
        }
      ]
    )
  end

  def foreign_key(from_table, from_column, to_table, to_column)
    TableSaw::ForeignKey.new from_table:,
                             from_column:,
                             to_table:,
                             to_column:
  end

  describe '#belongs_to' do
    it 'returns a set of foreign keys for books' do
      expect(associations.belongs_to['books']).to include foreign_key('books', 'author_id', 'authors', 'id')
    end

    it 'returns a set of foreign keys for chapter' do
      expect(associations.belongs_to['chapters']).to include foreign_key('chapters', 'book_id', 'books', 'id')
    end

    it 'returns a set of foreign keys for slugs' do
      expect(associations.belongs_to['slugs']).to include(
        foreign_key('slugs', 'sluggable_id:sluggable_type(Book)', 'books', 'id')
      )
    end
  end

  describe '#has_many' do
    it 'returns a set of foreign keys for authors' do
      expect(associations.has_many['authors']).to include foreign_key('books', 'author_id', 'authors', 'id')
    end

    it 'returns a set of foreign keys for books' do
      expect(associations.has_many['books']).to include foreign_key('chapters', 'book_id', 'books', 'id')
    end

    it 'returns polymorphic association for books' do
      expect(associations.has_many['books']).to include(
        foreign_key('slugs', 'sluggable_id:sluggable_type(Book)', 'books', 'id')
      )
    end
  end
end
