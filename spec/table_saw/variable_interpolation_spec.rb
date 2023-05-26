# frozen_string_literal: true

RSpec.describe TableSaw::VariableInterpolation do
  subject(:interpolation) { described_class.new(variables) }

  describe '#call' do
    context 'when variable is defined before it is referenced' do
      let(:variables) do
        {
          'author_id' => '123',
          'illustrator_id' => '%{author_id}',
          'book_id' => '%{invalid_key}'
        }
      end

      it 'interpolates variables' do
        expect(interpolation.call).to eq('author_id' => '123', 'illustrator_id' => '123', 'book_id' => '%{invalid_key}')
      end
    end

    context 'when variable is defined after it is referenced' do
      let(:variables) do
        {
          'illustrator_id' => '%{author_id}',
          'author_id' => '123',
          'book_id' => '%{illustrator_id}'
        }
      end

      it 'interpolates variables' do
        expect(interpolation.call).to eq('author_id' => '123', 'illustrator_id' => '123', 'book_id' => '123')
      end
    end
  end
end
