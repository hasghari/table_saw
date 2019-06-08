# frozen_string_literal: true

RSpec.describe TableSaw do
  it 'has a version number' do
    expect(TableSaw::VERSION).not_to be nil
  end

  describe '::configure' do
    let(:configuration) { instance_spy TableSaw::Configuration }

    before do
      allow(TableSaw).to receive(:configuration).and_return(configuration)
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
end
