# frozen_string_literal: true

RSpec.describe TableSaw::Queries::PrimaryKeys do
  subject(:query) { described_class.new }

  %w(authors books chapters).each do |table|
    it "returns id primary key for #{table}" do
      expect(query.call[table]).to eq 'id'
    end
  end

  it 'returns version primary key for schema_migrations' do
    expect(query.call['schema_migrations']).to eq 'version'
  end
end
