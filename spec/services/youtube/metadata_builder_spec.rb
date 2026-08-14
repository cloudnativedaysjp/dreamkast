require 'rails_helper'

RSpec.describe(Youtube::MetadataBuilder) do
  let!(:conference) { create(:cndt2020) }
  let!(:talk) { create(:talk1) }

  subject(:builder) { described_class.new(talk) }

  describe '#title' do
    it 'combines talk title and conference name' do
      expect(builder.title).to(eq('talk1 - CloudNative Days Tokyo 2020'))
    end

    it 'truncates to 100 characters' do
      allow(talk).to(receive(:title).and_return('a' * 200))
      expect(builder.title.length).to(eq(100))
    end

    it 'removes angle brackets' do
      allow(talk).to(receive(:title).and_return('<script>x</script>'))
      expect(builder.title).not_to(include('<', '>'))
    end
  end

  describe '#snippet' do
    it 'returns a hash with the expected keys' do
      expect(builder.snippet.keys).to(contain_exactly(:title, :description, :tags, :category_id))
    end
  end
end
