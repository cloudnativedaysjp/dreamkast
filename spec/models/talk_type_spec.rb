require 'rails_helper'

RSpec.describe(TalkType, type: :model) do
  describe 'validations' do
    it 'validates presence of name' do
      type = build(:talk_type, name: nil)
      expect(type).not_to(be_valid)
      expect(type.errors[:name]).to(include('を入力してください'))
    end

    it 'validates uniqueness of name' do
      create(:talk_type, name: 'test')
      duplicate = build(:talk_type, name: 'test')
      expect(duplicate).not_to(be_valid)
      expect(duplicate.errors[:name]).to(include('はすでに存在します'))
    end

    it 'validates name format' do
      invalid_names = ['Test', 'test-name', 'test name', '123test', 'test!']
      invalid_names.each do |name|
        type = build(:talk_type, name:)
        expect(type).not_to(be_valid, "#{name} should be invalid")
      end

      valid_names = ['test', 'test_name', 'keynote', 'sponsor_session']
      valid_names.each do |name|
        type = build(:talk_type, name:)
        expect(type).to(be_valid, "#{name} should be valid")
      end
    end

    it 'validates presence of display_name' do
      type = build(:talk_type, display_name: nil)
      expect(type).not_to(be_valid)
      expect(type.errors[:display_name]).to(include('を入力してください'))
    end
  end

  describe 'associations' do
    it 'has many talk_type_associations' do
      association = TalkType.reflect_on_association(:talk_type_associations)
      expect(association.macro).to(eq(:has_many))
      expect(association.options[:dependent]).to(eq(:destroy))
    end

    it 'has many talks through talk_type_associations' do
      association = TalkType.reflect_on_association(:talks)
      expect(association.macro).to(eq(:has_many))
      expect(association.options[:through]).to(eq(:talk_type_associations))
    end
  end

  describe 'scopes' do
    before do
      @exclusive_type = create(:talk_type, name: 'intermission', is_exclusive: true)
      @non_exclusive_type = create(:talk_type, name: 'keynote', is_exclusive: false)
    end

    it 'filters exclusive types' do
      expect(TalkType.exclusive).to(contain_exactly(@exclusive_type))
    end

    it 'filters non-exclusive types' do
      expect(TalkType.non_exclusive).to(contain_exactly(@non_exclusive_type))
    end

    it 'orders by display_name' do
      type_z = create(:talk_type, name: 'z_type', display_name: 'Z Type')
      type_a = create(:talk_type, name: 'a_type', display_name: 'A Type')

      expect(TalkType.ordered).to(eq([type_a, @exclusive_type, @non_exclusive_type, type_z]))
    end
  end

  describe 'class methods' do
    before do
      create(:talk_type, name: 'keynote')
      create(:talk_type, name: 'sponsor')
      create(:talk_type, name: 'intermission')
    end

    it 'finds keynote type' do
      keynote = TalkType.keynote
      expect(keynote.name).to(eq('keynote'))
    end

    it 'finds sponsor type' do
      sponsor = TalkType.sponsor
      expect(sponsor.name).to(eq('sponsor'))
    end

    it 'finds intermission type' do
      intermission = TalkType.intermission
      expect(intermission.name).to(eq('intermission'))
    end

    it 'raises error when type not found' do
      expect { TalkType.find_by!(name: 'nonexistent') }.to(raise_error(ActiveRecord::RecordNotFound))
    end
  end
end
