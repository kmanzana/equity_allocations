FactoryGirl.define do
  factory :user do
    first_name 'Alan'
    last_name 'Watts'
    email 'alan@watts.com'
    word_press_id 11
    username 'alanwatts'
    password_digest { SecureRandom.urlsafe_base64 }
  end
end
