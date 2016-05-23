class Account < ActiveRecord::Base
  belongs_to :investor

  validates :investor_id,    presence: true
  validates :routing_number, presence: true, length: { maximum: 9 }
  validates :account_number, presence: true, length: { maximum: 17 }
  validates :account_name,   presence: true, length: { maximum: 50 }

  def exists_in_crowd_pay?
    account_id?
  end
end
