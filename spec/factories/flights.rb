FactoryBot.define do
  factory :flight do
    drone
    pilot_id { "PL#{Faker::Number.number(digits: 11)}" }
    take_off_latitude { Faker::Number.between(from: -90.0, to: 90.0) }
    take_off_longitude { Faker::Number.between(from: -180.0, to: 180.0) }
    landing_latitude { Faker::Number.between(from: -90.0, to: 90.0) }
    landing_longitude { Faker::Number.between(from: -180.0, to: 180.0) }
    take_off_time { Faker::Time.between(from: DateTime.now - 1, to: DateTime.now, format: :default) }
    landing_time { take_off_time.to_date + 1.hour}
  end
end