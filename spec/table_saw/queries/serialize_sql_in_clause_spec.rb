# frozen_string_literal: true

RSpec.describe TableSaw::Queries::SerializeSqlInClause do
  subject(:query) { described_class.new(table_name, column, values) }

  describe '#call' do
    context 'when integer values' do
      let(:table_name) { 'authors' }
      let(:column) { 'id' }
      let(:values) { [1, 2, 3] }

      it 'returns correct clause' do
        expect(query.call).to eq 'id in (1, 2, 3)'
      end
    end

    context 'when string values' do
      let(:table_name) { 'schema_migrations' }
      let(:column) { 'version' }
      let(:values) { %w(20191011053718 20191112182214) }

      it 'returns correct clause' do
        expect(query.call).to eq "version in ('20191011053718', '20191112182214')"
      end
    end
  end
end
