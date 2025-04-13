# == Schema Information
#
# Table name: form_items
#
#  id            :bigint           not null, primary key
#  attr          :string(255)
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#

FactoryBot.define do
  factory :form_item do
    association :conference
    name { 'フォーム項目' }
    attr { 'form_field' }
  end

  factory :form_item1, class: FormItem do
    id { 1 }
    conference_id { 1 }
    name { 'IBMからのメールを希望する' }
    attr { 'ibm_email_consent' }
  end
  factory :form_item2, class: FormItem do
    id { 2 }
    conference_id { 1 }
    name { 'IBMからの電話を希望する' }
    attr { 'ibm_phone_consent' }
  end
  factory :form_item3, class: FormItem do
    id { 3 }
    conference_id { 1 }
    name { 'IBMからの郵便を希望する' }
    attr { 'ibm_mail_consent' }
  end
  factory :form_item4, class: FormItem do
    id { 4 }
    conference_id { 1 }
    name { '日本マイクロソフト株式会社への個人情報提供に同意する' }
    attr { 'microsoft_consent' }
  end
end
