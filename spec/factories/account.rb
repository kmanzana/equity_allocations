FactoryGirl.define do
  factory :account do
    association :investor, factory: [:investor, :in_crowd_pay]

    routing_number 987654321
    account_number 1234567890
    account_name 'Edward Abbey'

    trait :in_crowd_pay do
      crowd_pay_id 85712
    end
  end
end
