FactoryBot.define do
  factory :conference_day

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
  factory :cndo_day1, class: ConferenceDay do
    id { 10 }
    conference_id { 2 }
    date { '2021-03-11' }
    start_time { '03:00:00' }
    end_time { '11:00:00' }
    internal { false }
  end

  factory :cndo_day2, class: ConferenceDay do
    id { 11 }
    conference_id { 2 }
    date { '2021-03-12' }
    start_time { '03:00:00' }
    end_time { '11:00:00' }
    internal { false }
  end

  factory :one_day1, class: ConferenceDay do
    date { '2021-03-11' }
    start_time { '13:00' }
    end_time { '19:00' }
    internal { false }
  end

  factory :two_day1, class: ConferenceDay do
    date { '2021-03-11' }
    start_time { '13:00' }
    end_time { '19:00' }
    internal { false }
  end

  factory :internal, class: ConferenceDay do
    date { '2021-02-10' }
    start_time { '19:00' }
    end_time { '21:00' }
    internal { true }
  end

  factory :two_day2, class: ConferenceDay do
    date { '2021-03-12' }
    start_time { '13:00' }
    end_time { '19:00' }
    internal { false }
  end
  factory :cndt2021_day1, class: ConferenceDay do
    id { 13 }
    conference_id { 4 }
    date { '2021-03-11' }
    start_time { '13:00' }
    end_time { '19:00' }
    internal { false }
  end

  factory :cndt2021_day2, class: ConferenceDay do
    id { 14 }
    conference_id { 4 }
    date { '2021-03-12' }
    start_time { '13:00' }
    end_time { '19:00' }
    internal { false }
  end
end
