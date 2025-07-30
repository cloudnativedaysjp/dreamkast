FactoryBot.define do
  factory :room, class: Room do
    name { 'ONLINE' }
    number_of_seats { 100 }
    conference_id { 1 }
  end
end
