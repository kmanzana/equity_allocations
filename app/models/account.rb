class Account < ActiveRecord::Base
  belongs_to :investor
  has_many :investments, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :investor_id,    presence: true
  validates :routing_number, presence: true, length: { maximum: 9 }
  validates :account_number, presence: true, length: { maximum: 17 }
  validates :account_name,   presence: true, length: { maximum: 50 }

  delegate :user, :foreign_address?, :verified?, :email, to: :investor
  delegate :crowd_pay_id, to: :investor, prefix: true

  def exists_in_crowd_pay?
    crowd_pay_id?
  end

  def build_investment attributes
    investments.build attributes
  end
end
