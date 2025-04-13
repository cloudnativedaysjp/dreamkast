# == Schema Information
#
# Table name: form_values
#
#  id           :bigint           not null, primary key
#  value        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  form_item_id :bigint           not null
#  profile_id   :bigint           not null
#
# Indexes
#
#  index_form_values_on_form_item_id  (form_item_id)
#  index_form_values_on_profile_id    (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (form_item_id => form_items.id)
#  fk_rails_...  (profile_id => profiles.id)
#
require 'rails_helper'

RSpec.describe FormValue, type: :model do
  let(:conference) { create(:conference) }
  let(:profile) { create(:profile, conference: conference) }
  let(:form_item) { create(:form_item, conference: conference) }

  describe 'バリデーション' do
    it 'profile、form_item、valueがあれば有効であること' do
      form_value = FormValue.new(
        profile: profile,
        form_item: form_item,
        value: '回答内容'
      )
      expect(form_value).to be_valid
    end

    it 'valueがなければ無効であること' do
      form_value = FormValue.new(
        profile: profile,
        form_item: form_item,
        value: nil
      )
      expect(form_value).to be_invalid
      expect(form_value.errors[:value]).to include('を入力してください')
    end

    it '同じprofileとform_itemの組み合わせが既に存在する場合は無効であること' do
      create(:form_value, profile: profile, form_item: form_item, value: '最初の回答')
      
      form_value = FormValue.new(
        profile: profile,
        form_item: form_item,
        value: '2回目の回答'
      )
      expect(form_value).to be_invalid
      expect(form_value.errors[:profile_id]).to include('は既にこのフォーム項目に回答しています')
    end

    it 'valueが1000文字を超える場合は無効であること' do
      form_value = FormValue.new(
        profile: profile,
        form_item: form_item,
        value: 'a' * 1001
      )
      expect(form_value).to be_invalid
      expect(form_value.errors[:value]).to include('は1000文字以内で入力してください')
    end
  end

  describe 'アソシエーション' do
    it 'profileに属していること' do
      association = FormValue.reflect_on_association(:profile)
      expect(association.macro).to eq :belongs_to
    end

    it 'form_itemに属していること' do
      association = FormValue.reflect_on_association(:form_item)
      expect(association.macro).to eq :belongs_to
    end
  end
end
