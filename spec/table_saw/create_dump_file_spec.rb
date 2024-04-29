# frozen_string_literal: true

require 'spec_helper'
require 'table_saw/create_dump_file'

RSpec.describe TableSaw::CreateDumpFile do
  subject(:creator) { described_class.new(records, output: file, format:) }

  let(:records) do
    {
      'authors' => TableSaw::DependencyGraph::DumpTable.new(manifest:, name: 'authors', partial: false),
      'books' => TableSaw::DependencyGraph::DumpTable.new(manifest:, name: 'books', partial: false)
    }
  end

  let(:manifest) do
    TableSaw::Manifest.new(
      'tables' => [
        { 'table' => 'authors' }
      ]
    )
  end

  let(:file) { 'test.dump' }
  let(:format) { { 'type' => 'copy' } }

  before do
    Author.create!(id: 1, name: 'Dan Brown')
  end

  after do
    FileUtils.rm_f(file)
  end

  describe '#call' do
    it 'generates file' do
      creator.call
      expect(File.exist?(file)).to be true
    end
  end
end
