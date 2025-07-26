# == Schema Information
#
# Table name: form_items
#
#  id            :integer          not null, primary key
#  conference_id :integer
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  attr          :string(255)
#

require 'rails_helper'

RSpec.describe(FormItem, type: :model) do
  let(:conference) { create(:conference) }

  describe 'バリデーション' do
    it 'conference、name、attrがあれば有効であること' do
      form_item = FormItem.new(
        conference:,
        name: 'テストフォーム項目',
        attr: 'test_form_field'
      )
      expect(form_item).to(be_valid)
    end

    it 'nameがなければ無効であること' do
      form_item = FormItem.new(
        conference:,
        name: nil,
        attr: 'test_form_field'
      )
      expect(form_item).to(be_invalid)
      expect(form_item.errors[:name]).to(include('を入力してください'))
    end

    it 'attrがなければ無効であること' do
      form_item = FormItem.new(
        conference:,
        name: 'テストフォーム項目',
        attr: nil
      )
      expect(form_item).to(be_invalid)
      expect(form_item.errors[:attr]).to(include('を入力してください'))
    end
  end

  describe 'アソシエーション' do
    it 'conferenceに属していること' do
      association = FormItem.reflect_on_association(:conference)
      expect(association.macro).to(eq(:belongs_to))
    end

    it 'form_valuesを持っていること' do
      association = FormItem.reflect_on_association(:form_values)
      expect(association.macro).to(eq(:has_many))
    end

    it 'profilesを持っていること' do
      association = FormItem.reflect_on_association(:profiles)
      expect(association.macro).to(eq(:has_many))
    end
  end
end
