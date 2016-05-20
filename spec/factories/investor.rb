FactoryGirl.define do
  factory :investor do
    first_name 'Alan'
    middle_name 'James'
    last_name 'Watts'
    tax_id 123456789
    email 'alan@watts.com'
    birth_date { 30.years.ago }
    address1 '1234 Some St'
    city 'Somewhere'
    state 'IL'
    zip '12345'
  end
end
