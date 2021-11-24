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
    name { "IBM\u304B\u3089\u306E\u30E1\u30FC\u30EB\u3092\u5E0C\u671B\u3059\u308B" }
  end
  factory :form_item2, class: FormItem do
    id { 2 }
    conference_id { 1 }
    name { "IBM\u304B\u3089\u306E\u96FB\u8A71\u3092\u5E0C\u671B\u3059\u308B" }
  end
  factory :form_item3, class: FormItem do
    id { 3 }
    conference_id { 1 }
    name { "IBM\u304B\u3089\u306E\u90F5\u4FBF\u3092\u5E0C\u671B\u3059\u308B" }
  end
  factory :form_item4, class: FormItem do
    id { 4 }
    conference_id { 1 }
    name { "\u65E5\u672C\u30DE\u30A4\u30AF\u30ED\u30BD\u30D5\u30C8\u682A\u5F0F\u4F1A\u793E\u3078\u306E\u500B\u4EBA\u60C5\u5831\u63D0\u4F9B\u306B\u540C\u610F\u3059\u308B" }
  end
end
