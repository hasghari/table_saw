# frozen_string_literal: true

RSpec.describe TableSaw::InformationSchema do
  subject(:query) { described_class.new }

  describe '#constraint_names' do
    it 'returns hash of constraint names for table' do
      expect(query.constraint_names['books'].size).to eq 1
    end
  end
end
