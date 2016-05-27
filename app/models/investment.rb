class Investment < ActiveRecord::Base
  belongs_to :account
  has_many :transactions

  validates :terms, acceptance: true

  validates :account_id, presence: true
  validates :amount,     presence: true
end
