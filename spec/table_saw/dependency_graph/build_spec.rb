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
        expect(graph.call['books'].ids).to eq Set.new([1])
      end

      it 'fetches records for foreign keys when not listed explicitly' do
        expect(graph.call['authors'].ids).to eq Set.new([1])
      end
    end

    context 'with polymorphic table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'slugs', 'query' => 'select id from slugs where id = 1' }
          ],
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

      before do
        Slug.create!(id: 1, slug: 'angels-demons', sluggable_id: 1, sluggable_type: 'Book')
      end

      it 'fetches records for polymorphic foreign keys' do
        expect(graph.call['books'].ids).to eq Set.new([1])
      end
    end
  end

  context 'when has_many whitelisted' do
    before do
      Author.create!(id: 1, name: 'Dan Brown')
      Book.create!(id: 1, author_id: 1, name: 'Angels & Demons')
      Chapter.create!(id: 1, book_id: 1, title: 'Chapter 1')
      Chapter.create!(id: 2, book_id: 1, title: 'Chapter 2')
    end

    context 'with full table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'books' }
          ],
          'has_many' => {
            'books' => ['chapters']
          }
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
            { 'table' => 'books', 'query' => 'select id from books where id = 1' }
          ],
          'has_many' => {
            'books' => ['chapters']
          }
        )
      end

      it 'fetches associated has_many' do
        expect(graph.call['chapters'].ids).to eq Set.new([1, 2])
      end

      context 'with has_many scope' do
        let(:manifest) do
          TableSaw::Manifest.new(
            'tables' => [
              { 'table' => 'books', 'query' => 'select id from books where id = 1' }
            ],
            'has_many' => {
              'books' => [{ 'chapters' => { 'scope' => "title = 'Chapter 1'" } }]
            }
          )
        end

        it 'fetches associated has_many' do
          expect(graph.call['chapters'].ids).to eq Set.new([1])
        end
      end

      context 'with has_many limit' do
        let(:manifest) do
          TableSaw::Manifest.new(
            'tables' => [
              { 'table' => 'books', 'query' => 'select id from books where id = 1' }
            ],
            'has_many' => {
              'books' => [{ 'chapters' => { 'limit' => 1 } }]
            }
          )
        end

        it 'fetches associated has_many' do
          expect(graph.call['chapters'].ids).to(satisfy { |v| Set.new([1, 2]).superset?(v) })
        end
      end
    end

    context 'when scoped to partial' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'books', 'query' => 'select id from books where id = 1', 'has_many' => ['chapters'] }
          ],
          'has_many' => {
            'authors' => ['books']
          }
        )
      end

      before do
        Book.create!(id: 2, author_id: 1, name: 'Origin')
        Chapter.create!(id: 3, book_id: 2)
      end

      it 'only fetches chapters in scope' do
        expect(graph.call['chapters'].ids).to eq Set.new([1, 2])
      end
    end
  end

  context 'when foreign_keys (polymorphic) listed' do
    before do
      Author.create!(id: 1, name: 'Dan Brown')
      Book.create!(id: 1, author_id: 1, name: 'Angels & Demons')
      Chapter.create!(id: 1, book_id: 1)
      Chapter.create!(id: 2, book_id: 1)
      Slug.create!(id: 1, slug: 'angels-demons', sluggable_id: 1, sluggable_type: 'Book')
    end

    context 'with full table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'books' }
          ],
          'has_many' => {
            'books' => ['slugs']
          },
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

      it 'fetches associated has_many' do
        expect(graph.call.keys).to match_array %w(authors books slugs)
      end

      it 'has full dump tables for all' do
        expect(graph.call.values).to all(have_attributes(partial: false))
      end
    end

    context 'with partial table' do
      let(:manifest) do
        TableSaw::Manifest.new(
          'tables' => [
            { 'table' => 'books', 'query' => 'select id from books where id = 1' }
          ],
          'has_many' => {
            'books' => ['slugs']
          },
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

      it 'fetches associated has_many' do
        expect(graph.call['slugs'].ids).to eq Set.new([1])
      end
    end
  end
end
