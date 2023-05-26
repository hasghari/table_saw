# frozen_string_literal: true

RSpec.describe TableSaw::Configuration do
  subject(:config) { described_class.new }

  describe '#url=' do
    before do
      config.url = 'postgres://hamed:asghari@compute.aws.com:5432/meerkat'
    end

    it 'assigns host' do
      expect(config.host).to eq 'compute.aws.com'
    end

    it 'assigns port' do
      expect(config.port).to eq 5432
    end

    it 'assigns dbname' do
      expect(config.dbname).to eq 'meerkat'
    end

    it 'assigns user' do
      expect(config.user).to eq 'hamed'
    end

    it 'assigns password' do
      expect(config.password).to eq 'asghari'
    end
  end

  describe '#variables' do
    it 'is not nil' do
      expect(config.variables).not_to be_nil
    end

    it 'is a hash' do
      expect(config.variables).to be_a Hash
    end
  end
end
