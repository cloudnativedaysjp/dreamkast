require 'rails_helper'

RSpec.describe(SessionAttribute, type: :model) do
  describe 'validations' do
    it 'validates presence of name' do
      attribute = build(:session_attribute, name: nil)
      expect(attribute).not_to(be_valid)
      expect(attribute.errors[:name]).to(include('を入力してください'))
    end

    it 'validates uniqueness of name' do
      create(:session_attribute, name: 'test')
      duplicate = build(:session_attribute, name: 'test')
      expect(duplicate).not_to(be_valid)
      expect(duplicate.errors[:name]).to(include('はすでに存在します'))
    end

    it 'validates name format' do
      invalid_names = ['Test', 'test-name', 'test name', '123test', 'test!']
      invalid_names.each do |name|
        attribute = build(:session_attribute, name:)
        expect(attribute).not_to(be_valid, "#{name} should be invalid")
      end

      valid_names = ['test', 'test_name', 'keynote', 'sponsor_session']
      valid_names.each do |name|
        attribute = build(:session_attribute, name:)
        expect(attribute).to(be_valid, "#{name} should be valid")
      end
    end

    it 'validates presence of display_name' do
      attribute = build(:session_attribute, display_name: nil)
      expect(attribute).not_to(be_valid)
      expect(attribute.errors[:display_name]).to(include('を入力してください'))
    end
  end

  describe 'associations' do
    it 'has many talk_session_attributes' do
      association = SessionAttribute.reflect_on_association(:talk_session_attributes)
      expect(association.macro).to(eq(:has_many))
      expect(association.options[:dependent]).to(eq(:destroy))
    end

    it 'has many talks through talk_session_attributes' do
      association = SessionAttribute.reflect_on_association(:talks)
      expect(association.macro).to(eq(:has_many))
      expect(association.options[:through]).to(eq(:talk_session_attributes))
    end
  end

  describe 'scopes' do
    before do
      @exclusive_attr = create(:session_attribute, name: 'intermission', is_exclusive: true)
      @non_exclusive_attr = create(:session_attribute, name: 'keynote', is_exclusive: false)
    end

    it 'filters exclusive attributes' do
      expect(SessionAttribute.exclusive).to(contain_exactly(@exclusive_attr))
    end

    it 'filters non-exclusive attributes' do
      expect(SessionAttribute.non_exclusive).to(contain_exactly(@non_exclusive_attr))
    end

    it 'orders by display_name' do
      attr_z = create(:session_attribute, name: 'z_attr', display_name: 'Z Attribute')
      attr_a = create(:session_attribute, name: 'a_attr', display_name: 'A Attribute')

      expect(SessionAttribute.ordered).to(eq([attr_a, @exclusive_attr, @non_exclusive_attr, attr_z]))
    end
  end

  describe 'class methods' do
    before do
      create(:session_attribute, name: 'keynote')
      create(:session_attribute, name: 'sponsor')
      create(:session_attribute, name: 'intermission')
    end

    it 'finds keynote attribute' do
      keynote = SessionAttribute.keynote
      expect(keynote.name).to(eq('keynote'))
    end

    it 'finds sponsor attribute' do
      sponsor = SessionAttribute.sponsor
      expect(sponsor.name).to(eq('sponsor'))
    end

    it 'finds intermission attribute' do
      intermission = SessionAttribute.intermission
      expect(intermission.name).to(eq('intermission'))
    end

    it 'raises error when attribute not found' do
      expect { SessionAttribute.find_by!(name: 'nonexistent') }.to(raise_error(ActiveRecord::RecordNotFound))
    end
  end
end
