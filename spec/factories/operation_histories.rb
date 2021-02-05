FactoryBot.define do
  factory :operation_history do
    sleep_at { Time.current }
    user { FactoryBot.create :user }
  end
end
