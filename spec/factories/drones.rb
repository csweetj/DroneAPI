FactoryBot.define do
  factory :drone do
    drone_registration_id { "JU" + Array.new(11) { (('0'..'9').to_a + ('A'..'Z').to_a).sample }.join }
  end
end