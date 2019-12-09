# frozen_string_literal: true

RSpec.describe TableSaw::Queries::ExecuteInsertStatement do
  subject(:query) { described_class.new(statement, row) }

  let(:statement) { OpenStruct.new(name: name, table_name: table_name) }

  describe '#call' do
    context 'with authors table' do
      let(:name) { 'authors_insert_plan' }
      let(:table_name) { 'authors' }
      let(:row) { ['1', 'Dan Brown'] }

      it 'returns correct statement' do
        expect(query.call).to eq "EXECUTE authors_insert_plan(1, 'Dan Brown');"
      end
    end

    context 'with books table' do
      let(:name) { 'books_insert_plan' }
      let(:table_name) { 'books' }
      let(:row) { ['8', '34', 'Digital Fortress'] }

      it 'returns correct statement' do
        expect(query.call).to eq "EXECUTE books_insert_plan(8, 34, 'Digital Fortress');"
      end
    end
  end
end
