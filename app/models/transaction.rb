class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :investment
end
