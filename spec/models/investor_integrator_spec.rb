describe InvestorIntegrator do
  let(:investor) { FactoryGirl.create :investor, :new }
  let(:attributes) { FactoryGirl.attributes_for :investor, :ready_for_crowd_pay }

  let(:verification) do
    double.tap do |mock|
      allow(mock).to receive(:pass?).and_return(true)
    end
  end

  let(:crowd_pay_investor) do
    double.tap do |mock|
      allow(mock).to receive(:id).and_return(82185)
      allow(mock).to receive(:investor_key)
      .and_return('7a6497b1-e855-4055-8cf6-c2e7be34bf50')
    end
  end

  before do
    allow(CrowdPay::Verification).to receive(:verify)
    .and_return(verification)

    allow(CrowdPay::Investor).to receive(:create)
    .and_return(crowd_pay_investor)
  end

  describe '#verify_and_create_external_investor' do
    it 'updates investor attributes' do
      expect(investor.tax_id).to be_nil

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(investor.tax_id).to eq(attributes[:tax_id])
    end

    it 'does nothing else if investor is not valid for crowd_pay' do
      attributes[:tax_id] = 12345

      expect(CrowdPay::Verification).to_not receive(:verify)
      expect(CrowdPay::Investor).to_not receive(:create)

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor
    end

    it 'verifies investor identity' do
      expect(CrowdPay::Verification).to receive(:verify) do |params|
        expect(params[:firstName]).to eq(investor.first_name)
        expect(params[:birthMonth]).to eq(2)
        expect(params[:birthDay]).to eq(3)
        expect(params[:birthYear]).to eq(1991)

        verification
      end

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor
    end

    it 'updates verified to true on investor' do
      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(investor.verified).to be_truthy
    end

    it 'creates investor if verification passes' do
      expect(CrowdPay::Investor).to receive(:create) do |params|
        expect(params[:first_name]).to eq(investor.first_name)
        expect(params[:tax_id_number]).to eq(investor.tax_id)
        expect(params[:created_by_ip_address]).to eq('123.456.789.012')
        expect(params[:birth_date]).to eq('1991-02-03 00:00:00')
        expect(params[:is_cip_satisfied]).to be_truthy
        crowd_pay_investor
      end

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor
    end

    it 'does not create investor if verification fails' do
      allow(verification).to receive(:pass?).and_return(false)
      expect(CrowdPay::Investor).to_not receive(:create)

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor
    end

    it 'saves investor_id and investor_key after create investor' do
      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(investor.investor_id).to eq(crowd_pay_investor.id)
      expect(investor.investor_key).to eq(crowd_pay_investor.investor_key)
    end
  end

  describe '#success?' do
    it 'returns false when update_attributes fails' do
      attributes[:first_name] = ''

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(integrator).to_not be_success
    end

    it 'returns false when investor is not valid for crowd_pay' do
      attributes[:tax_id] = 12345

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(integrator).to_not be_success
    end

    it 'returns false when verification fails' do
      allow(verification).to receive(:pass?).and_return(false)

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(integrator).to_not be_success
    end

    it 'returns false when investor creation fails' do
      allow(crowd_pay_investor).to receive(:errors).and_return(['test error'])

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(integrator).to_not be_success
    end

    it 'returns true when everything works' do
      allow(crowd_pay_investor).to receive(:errors).and_return([])

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(integrator).to be_success
    end
  end

  describe 'error' do
    before do
      allow(verification).to receive(:fail?).and_return(false)
      allow(verification).to receive(:soft_fail?).and_return(false)
    end

    # might not be necessary if errors automatically show up from @investor in controller
    # it 'returns investor model attribute errors when update fails'

    it 'tailors error message when verification fails' do
      allow(verification).to receive(:fail?).and_return(true)

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(integrator.error).to include('Investor identification verification failed')
    end

    it 'tailors error message when investor creation fails' do
      allow(crowd_pay_investor).to receive(:errors).and_return(['test error'])

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(integrator.error).to include('Investor creation failed')
    end

    it 'returns nil if no tailored message' do
      attributes[:first_name] = ''

      integrator = InvestorIntegrator.new investor, attributes, '123.456.789.012'
      integrator.verify_and_create_external_investor

      expect(integrator.error).to be_nil
    end
  end
end
