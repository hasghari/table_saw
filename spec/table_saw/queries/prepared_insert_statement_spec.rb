# frozen_string_literal: true

RSpec.describe TableSaw::Queries::PreparedInsertStatement do
  subject(:query) { described_class.new(table_name, options:) }

  let(:options) { {} }

  describe '#call' do
    context 'with authors table' do
      let(:table_name) { 'authors' }

      it 'returns a prepared statement' do
        expect(query.call.sql).to eq <<~SQL.squish
          PREPARE authors_insert_plan (bigint, character varying) AS INSERT INTO authors ("id", "name") VALUES ($1, $2);
        SQL
      end
    end

    context 'when ignore conflict' do
      let(:table_name) { 'authors' }
      let(:options) { { 'ignore_conflict' => 'true' } }

      it 'returns prepared statement with do nothing on conflict' do
        expect(query.call.sql).to eq <<~SQL.squish
          PREPARE authors_insert_plan (bigint, character varying) AS INSERT INTO authors ("id", "name") VALUES ($1, $2)
            ON CONFLICT DO NOTHING;
        SQL
      end
    end

    context 'with books table' do
      let(:table_name) { 'books' }

      it 'returns a prepared statement' do
        expect(query.call.sql).to eq <<~SQL.squish
          PREPARE books_insert_plan (bigint, bigint, character varying, character varying[], json)
            AS INSERT INTO books ("id", "author_id", "name", "tags", "metadata") VALUES ($1, $2, $3, $4, $5);
        SQL
      end
    end

    context 'when a column name is a reserved word' do
      let(:table_name) { 'magazines' }

      it 'returns a prepared statement' do
        expect(query.call.sql).to eq <<~SQL.squish
          PREPARE magazines_insert_plan (bigint, character varying, character varying)
            AS INSERT INTO magazines ("id", "title", "from") VALUES ($1, $2, $3);
        SQL
      end
    end
  end
end
