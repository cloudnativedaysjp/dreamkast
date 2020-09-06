FactoryBot.define do
  factory :cndt2020, class: Conference do
    id { 1 }
    name { 'CloudNative Days Tokyo 2020'}
    abbr { 'cndt2020' }
    status { 0 }
  end

  factory :cndt2020_opened, class: Conference do
    id { 1 }
    name { 'CloudNative Days Tokyo 2020'}
    abbr { 'cndt2020' }
    status { 1 }
  end

  factory :cndt2020_closed, class: Conference do
    id { 1 }
    name { 'CloudNative Days Tokyo 2020'}
    abbr { 'cndt2020' }
    status { 2 }
  end
end