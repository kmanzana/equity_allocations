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

  def account
    investor && investor.account
  end

  def investor_exists_in_crowd_pay?
    investor && investor.exists_in_crowd_pay?
  end
end
