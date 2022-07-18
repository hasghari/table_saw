# frozen_string_literal: true

require 'table_saw/version'

RSpec.describe TableSaw do
  it 'has a version number' do
    expect(TableSaw::VERSION).not_to be nil
  end

  describe '::configure' do
    let(:configuration) { instance_spy TableSaw::Configuration }

    before do
      allow(described_class).to receive(:configuration).and_return(configuration)
    end

    it 'can accept a block' do
      described_class.configure { |config| config.dbname = 'meerkat' }
      expect(configuration).to have_received(:dbname=).with('meerkat')
    end

    it 'can accept a hash' do
      described_class.configure(dbname: 'meerkat')
      expect(configuration).to have_received(:dbname=).with('meerkat')
    end
  end

  describe '::primary_key' do
    context 'when table has a single primary key' do
      it 'returns the first primary key found' do
        expect(described_class.primary_key('books')).to eq('id')
      end
    end

    context 'when table has multiple primary keys' do
      it 'returns the primary key' do
        expect(described_class.primary_key('revisions')).to eq('book_id')
      end
    end
  end
end
