class InvestorIntegrator
  def initialize investor, attributes, ip
    @investor = investor
    @attributes = attributes
    @ip = ip
  end

  def verify_and_create_external_investor
    investor.update_attributes attributes

    if investor.valid_for_crowd_pay?
      verify
      create if verification.pass?
    end
  end

  def success?
    investor.valid_for_crowd_pay? && verification.pass? &&
    crowd_pay_investor.errors.empty?
  end

  def error
    if verification && (verification.fail? || verification.soft_fail?)
      'Investor identification verification failed'
    elsif crowd_pay_investor && crowd_pay_investor.errors.any?
      'Investor creation failed'
    end
  end

  # def soft_fail?
  # end

  private

  attr_reader :investor, :attributes, :ip, :verification, :crowd_pay_investor

  def verify
    @verification = CrowdPay::Verification.verify verify_params, by_pass

    investor.update_attributes(verified: true) if verification.pass?
  end

  def create
    @crowd_pay_investor = CrowdPay::Investor.create create_investor_params

    investor.update_attributes crowd_pay_id: crowd_pay_investor.id,
                               crowd_pay_key: crowd_pay_investor.investor_key

    # upload acceptance document
  end

  def verify_params
    {
      firstName: investor.first_name,
      lastName: investor.last_name,
      address: investor.address1,
      city: investor.city,
      state: investor.state,
      zip: investor.zip,
      taxpayerId: investor.tax_id,
      birthMonth: investor.birth_date.month,
      birthDay: investor.birth_date.day,
      birthYear: investor.birth_date.year
    }
  end

  def create_investor_params
    {
      tax_id_number: investor.tax_id,
      first_name: investor.first_name,
      middle_name: investor.middle_name,
      last_name: investor.last_name,
      birth_date: investor.birth_date.to_s(:db),
      is_mailing_address_foreign: investor.foreign_address?,
      legal_address_1: investor.address1,
      legal_address_2: investor.address2,
      legal_city: investor.city,
      legal_state: investor.state,
      legal_zip: investor.zip,
      is_person: investor.person?,
      is_cip_satisfied: investor.verified?,
      created_by_ip_address: ip
    }
  end

  def by_pass
    # by pass any investor info besides this tax id
    investor.tax_id != 112223333
  end
end
