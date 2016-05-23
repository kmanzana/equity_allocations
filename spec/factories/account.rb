FactoryGirl.define do
  factory :account do
    investor

    routing_number 987654321
    account_number 1234567890
    account_name 'Edward Abbey'

    trait :in_crowd_pay do
      account_id 85712
    end
  end
end
