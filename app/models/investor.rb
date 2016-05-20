class Investor < ActiveRecord::Base
  belongs_to :user
  # has_one :account

  # acceptance validation?

  validates :first_name,  presence: true, length: { maximum: 50 }, if: :person?
  validates :middle_name, presence: true, length: { maximum: 50 }, if: :person?
  validates :last_name,   presence: true, length: { maximum: 50 }, if: :person?
  validates :organization_name, presence: true, length: { maximum: 150 }, unless: :person?
  validate :correct_name_presence

  validate :tax_id_length
  validates_presence_of :birth_date

  validates :address1, presence: true, length: { maximum: 40 }
  validates :address2,                 length: { maximum: 40 }
  validates :city,     presence: true, length: { maximum: 40 }
  validates :state,    presence: true, length: { maximum: 30 }
  validates :zip,      presence: true, length: { maximum: 9 }

  before_save { email.downcase! if email }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 50 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  private

  def tax_id_length
    length = tax_id.to_s.length

    if length > 9
      errors.add :tax_id, 'can\'t be more than 9 digits'
    elsif length < 9
      errors.add :tax_id, 'can\'t be less than 9 digits'
    end
  end

  def correct_name_presence
    if person?
      unless organization_name.nil?
        errors.add :organization_name, 'should not be present for a person'
      end
    else
      message = 'should not be present for an organization'
      errors.add(:first_name, message) unless first_name.blank?
      errors.add(:middle_name, message) unless first_name.blank?
      errors.add(:last_name, message) unless first_name.blank?
    end
  end
end
