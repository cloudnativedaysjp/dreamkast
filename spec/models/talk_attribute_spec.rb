require 'rails_helper'

RSpec.describe(TalkAttribute, type: :model) do
  describe 'validations' do
    it 'validates presence of name' do
      attribute = build(:talk_attribute, name: nil)
      expect(attribute).not_to(be_valid)
      expect(attribute.errors[:name]).to(include('を入力してください'))
    end

    it 'validates uniqueness of name' do
      create(:talk_attribute, name: 'test')
      duplicate = build(:talk_attribute, name: 'test')
      expect(duplicate).not_to(be_valid)
      expect(duplicate.errors[:name]).to(include('はすでに存在します'))
    end

    it 'validates name format' do
      invalid_names = ['Test', 'test-name', 'test name', '123test', 'test!']
      invalid_names.each do |name|
        attribute = build(:talk_attribute, name:)
        expect(attribute).not_to(be_valid, "#{name} should be invalid")
      end

      valid_names = ['test', 'test_name', 'keynote', 'sponsor_session']
      valid_names.each do |name|
        attribute = build(:talk_attribute, name:)
        expect(attribute).to(be_valid, "#{name} should be valid")
      end
    end

    it 'validates presence of display_name' do
      attribute = build(:talk_attribute, display_name: nil)
      expect(attribute).not_to(be_valid)
      expect(attribute.errors[:display_name]).to(include('を入力してください'))
    end
  end

  describe 'associations' do
    it 'has many talk_talk_attributes' do
      association = TalkAttribute.reflect_on_association(:talk_talk_attributes)
      expect(association.macro).to(eq(:has_many))
      expect(association.options[:dependent]).to(eq(:destroy))
    end

    it 'has many talks through talk_talk_attributes' do
      association = TalkAttribute.reflect_on_association(:talks)
      expect(association.macro).to(eq(:has_many))
      expect(association.options[:through]).to(eq(:talk_talk_attributes))
    end
  end

  describe 'scopes' do
    before do
      @exclusive_attr = create(:talk_attribute, name: 'intermission', is_exclusive: true)
      @non_exclusive_attr = create(:talk_attribute, name: 'keynote', is_exclusive: false)
    end

    it 'filters exclusive attributes' do
      expect(TalkAttribute.exclusive).to(contain_exactly(@exclusive_attr))
    end

    it 'filters non-exclusive attributes' do
      expect(TalkAttribute.non_exclusive).to(contain_exactly(@non_exclusive_attr))
    end

    it 'orders by display_name' do
      attr_z = create(:talk_attribute, name: 'z_attr', display_name: 'Z Attribute')
      attr_a = create(:talk_attribute, name: 'a_attr', display_name: 'A Attribute')

      expect(TalkAttribute.ordered).to(eq([attr_a, @exclusive_attr, @non_exclusive_attr, attr_z]))
    end
  end

  describe 'class methods' do
    before do
      create(:talk_attribute, name: 'keynote')
      create(:talk_attribute, name: 'sponsor')
      create(:talk_attribute, name: 'intermission')
    end

    it 'finds keynote attribute' do
      keynote = TalkAttribute.keynote
      expect(keynote.name).to(eq('keynote'))
    end

    it 'finds sponsor attribute' do
      sponsor = TalkAttribute.sponsor
      expect(sponsor.name).to(eq('sponsor'))
    end

    it 'finds intermission attribute' do
      intermission = TalkAttribute.intermission
      expect(intermission.name).to(eq('intermission'))
    end

    it 'raises error when attribute not found' do
      expect { TalkAttribute.find_by!(name: 'nonexistent') }.to(raise_error(ActiveRecord::RecordNotFound))
    end
  end
end
