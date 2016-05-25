FactoryGirl.define do
  factory :user do
    username 'alanwatts'
    word_press_id 11
  end

  trait :with_investor do
    after(:create) do |instance|
      FactoryGirl.create :investor, :in_crowd_pay, user: instance
    end
  end

  trait :with_account do
    with_investor

    after(:create) do |instance|
      FactoryGirl.create :account, :in_crowd_pay, investor: instance.investor
    end
  end
end
