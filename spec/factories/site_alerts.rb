FactoryBot.define do
  factory :site_alert do
    machine_name { "alert_#{SecureRandom.hex(4)}" }
    message { "MyText" }
    user_id { 1 }
    publish_at { "2023-01-16 12:31:05" }
    unpublish_at { "2023-01-16 12:31:05" }
  end
end
