# == Schema Information
#
# Table name: form_items
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#
FactoryBot.define do
  factory :form_item1, class: FormItem do
    id { 1 }
    conference_id { 1 }
    name { "IBMからのメールを希望する" }
  end
  factory :form_item2, class: FormItem do
    id { 2 }
    conference_id { 1 }
    name { "IBMからの電話を希望する" }
  end
  factory :form_item3, class: FormItem do
    id { 3 }
    conference_id { 1 }
    name { "IBMからの郵便を希望する" }
  end
  factory :form_item4, class: FormItem do
    id { 4 }
    conference_id { 1 }
    name { "日本マイクロソフト株式会社への個人情報提供に同意する" }
  end
end
