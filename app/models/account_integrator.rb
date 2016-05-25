class AccountIntegrator
  def initialize account, attributes, ip
    @account = account
    @attributes = attributes
    @ip = ip
  end

  def create_external_account
    if account.update_attributes attributes
      @crowd_pay_account = CrowdPay::Account.create create_account_params
      account.update_attributes crowd_pay_id: crowd_pay_account.id
    end

    # upload acceptance doc
  end

  def success?
    account.valid? && crowd_pay_account.errors.empty?
  end

  def error
    if crowd_pay_account && crowd_pay_account.errors && crowd_pay_account.errors.any?
      'Account creation failed'
    end
  end

  private

  attr_reader :account, :attributes, :ip, :crowd_pay_account

  def create_account_params
    {
      investor_id: account.investor_crowd_pay_id,
      is_mailing_address_foreign: account.foreign_address?,
      is_cip_satisfied: account.verified?,
      draft_account_type_id: 1,
      draft_routing_number: account.routing_number,
      draft_account_number: account.account_number,
      draft_account_name: account.account_name,
      status_id: 1,
      account_type_id: 12,
      contact_email: account.email,
      created_by_ip_address: ip
    }
  end
end
