FactoryBot.define do
  factory :day1, class: ConferenceDay do
    id { 1 }
    conference_id { 1 }
    date { '2020-09-08' }
    start_time { '03:00:00' }
    end_time { '11:00:00' }
    internal { false }
  end

  factory :day2, class: ConferenceDay do
    id { 2 }
    conference_id { 1 }
    date { '2020-09-09' }
    start_time { '03:00:00' }
    end_time { '11:00:00' }
    internal { false }
  end

  factory :rejekt, class: ConferenceDay do
    id { 3 }
    conference_id { 3 }
    date { '2020-09-02' }
    start_time { '19:00:00' }
    end_time { '21:00:00' }
    internal { true }
  end
end
