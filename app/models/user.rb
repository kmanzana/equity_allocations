class User < ActiveRecord::Base
  has_one :investor, dependent: :destroy
  attr_accessor :remember_token

  validates_presence_of :word_press_id, :username

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create string, cost: cost
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  delegate :account, to: :investor, allow_nil: true
  delegate :build_investment, to: :account
  delegate :exists_in_crowd_pay?, to: :investor, prefix: true, allow_nil: true
  delegate :exists_in_crowd_pay?, to: :account, prefix: true, allow_nil: true

  def remember
     self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def get_or_build_account
    account || build_account
  end

  private

  delegate :build_account, to: :investor
end
