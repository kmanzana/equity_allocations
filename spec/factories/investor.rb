FactoryGirl.define do
  factory :investor do
    trait :new do
      first_name 'Alan'
      last_name 'Watts'
      email 'alan@watts.com'
      person true
    end

    trait :ready_for_crowd_pay do
      middle_name 'James'
      tax_id 123456789
      birth_date Date.new(1991, 2, 3)
      address1 '1234 Some St'
      city 'Somewhere'
      state 'IL'
      zip '12345'
    end

    factory :investor_ready_for_crowd_pay, traits: [:new, :ready_for_crowd_pay]
  end
end
