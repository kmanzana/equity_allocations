describe AccountIntegrator do
  let(:account) { FactoryGirl.create :account }

  let(:crowd_pay_account) do
    double.tap do |mock|
      allow(mock).to receive(:id).and_return(82185)
      allow(mock).to receive(:errors).and_return(nil)
    end
  end

  before do
    allow(CrowdPay::Account).to receive(:create)
    .and_return(crowd_pay_account)
  end

  describe '#create_external_account' do
    let(:attributes) { FactoryGirl.attributes_for :account, savings_account: true }

    it 'updates account' do
      expect(account).to_not be_savings_account

      integrator = AccountIntegrator.new account, attributes, '0.0.0.0'
      integrator.create_external_account

      account.reload
      expect(account).to be_savings_account
    end

    it 'updates account even if it is a new account' do
      new_account = FactoryGirl.build :account

      expect(new_account).to be_valid
      expect(new_account).to be_new_record
      expect(new_account).to_not be_savings_account

      integrator = AccountIntegrator.new new_account, attributes, '0.0.0.0'
      integrator.create_external_account

      expect(new_account).to be_savings_account
    end

    it 'creates crowd_pay account if account update succeeds' do
      expect(account).to be_verified

      expect(CrowdPay::Account).to receive(:create) do |params|
        expect(params[:investor_id]).to equal(account.investor_crowd_pay_id)
        expect(params[:is_mailing_address_foreign]).to equal(account.foreign_address?)
        expect(params[:is_cip_satisfied]).to equal(account.verified?)
        expect(params[:draft_account_type_id]).to equal(1)
        expect(params[:draft_routing_number]).to equal(account.routing_number)
        expect(params[:draft_account_number]).to equal(account.account_number)
        expect(params[:draft_account_name]).to equal(account.account_name)
        expect(params[:status_id]).to equal(1)
        expect(params[:account_type_id]).to equal(12)
        expect(params[:contact_email]).to eq(account.email)
        expect(params[:created_by_ip_address]).to eq('0.0.0.0')

        crowd_pay_account
      end

      integrator = AccountIntegrator.new account, attributes, '0.0.0.0'
      integrator.create_external_account
    end

    it 'does not create external account if account update fails' do
      attributes[:routing_number] = 1234567890

      expect(CrowdPay::Account).to_not receive(:create)

      integrator = AccountIntegrator.new account, attributes, '0.0.0.0'
      integrator.create_external_account
    end

    it 'updates account with crowd_pay_id if create account succeeds' do
      integrator = AccountIntegrator.new account, attributes, '0.0.0.0'
      integrator.create_external_account

      expect(account.crowd_pay_id).to equal(crowd_pay_account.id)
    end
  end

  describe '#success?' do
    before { allow(crowd_pay_account).to receive(:errors).and_return([]) }

    it 'returns true if account is valid and no errors on creation' do
      integrator = AccountIntegrator.new account, {}, '0.0.0.0'
      integrator.create_external_account

      expect(integrator).to be_success
    end

    it 'returns false if account invalid' do
      integrator = AccountIntegrator.new account, {
          routing_number: 1234567890
        }, '0.0.0.0'

      integrator.create_external_account

      expect(integrator).to_not be_success
    end

    it 'returns false if creation errors' do
      expect(crowd_pay_account).to receive(:errors).and_return(['error'])

      integrator = AccountIntegrator.new account, {}, '0.0.0.0'
      integrator.create_external_account

      expect(integrator).to_not be_success
    end
  end

  describe '#error' do
    it 'tailors message if investor creation fails' do
      allow(crowd_pay_account).to receive(:errors).and_return(['test error'])

      integrator = AccountIntegrator.new account, {}, '0.0.0.0'
      integrator.create_external_account

      expect(integrator.error).to include('Account creation failed')
    end

    it 'returns nil if validation fails' do
      integrator = AccountIntegrator.new account, {
          routing_number: 1234567890
        }, '0.0.0.0'

      integrator.create_external_account
      expect(integrator.error).to be_nil
    end

    it 'returns nil if no issues' do
      integrator = AccountIntegrator.new account, {}, '0.0.0.0'
      integrator.create_external_account

      expect(integrator.error).to be_nil
    end
  end
end
