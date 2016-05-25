class Investor < ActiveRecord::Base
  belongs_to :user
  has_one :account, dependent: :destroy

  # acceptance validation?

  validates_presence_of :user_id
  validates :first_name,  presence: true, length: { maximum: 50 }, if: :person?
  validates :middle_name, length: { maximum: 50 }, if: :person?
  validates :last_name,   presence: true, length: { maximum: 50 }, if: :person?
  validates :organization_name, presence: true, length: { maximum: 150 }, unless: :person?
  validate :correct_name_presence

  validates :address1, length: { maximum: 40 }
  validates :address2, length: { maximum: 40 }
  validates :city,     length: { maximum: 40 }
  validates :state,    length: { maximum: 30 }
  validates :zip,      length: { maximum: 9 }

  before_save { email.downcase! if email }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 50 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  def valid_for_crowd_pay?
    present?(:middle_name, :address1, :city, :state, :zip, :birth_date) &&
    tax_id_length_valid? && valid?
  end

  def exists_in_crowd_pay?
    crowd_pay_id?
  end

  private

  def present? *attributes
    attributes.reduce(true) do |all_present, attribute|
      present = send(attribute).present?
      errors.add(attribute, 'can\'t be blank') unless present
      all_present && present
    end
  end

  def tax_id_length_valid?
    (tax_id.to_s.length == 9).tap do |valid|
      errors.add(:tax_id, 'tax id must be 9 digits') unless valid
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
