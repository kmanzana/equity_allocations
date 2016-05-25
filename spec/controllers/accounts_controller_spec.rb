describe AccountsController do
  describe 'GET #billing_info' do
    let(:user) { FactoryGirl.create :user, :with_investor }

    before { log_in_as user }

    it 'redirects to confirm_path if account exists' do
      expect(controller.current_user).to receive(:account_exists_in_crowd_pay?).and_return(true)

      get :billing_info

      expect(response).to redirect_to(confirm_path)
    end

    it 'redirects to personal_info_path if investor does not exist' do
      expect(controller.current_user).to receive(:investor_exists_in_crowd_pay?).and_return(false)

      get :billing_info

      expect(response).to redirect_to(personal_info_path)
    end

    it 'assigns account as new built account' do
      get :billing_info

      expect(assigns[:account]).to be_an(Account)
      expect(assigns[:account]).to be_new_record
    end

    it 'assigns account as account if already existing' do
      FactoryGirl.create :account, investor: user.investor

      get :billing_info

      expect(assigns[:account]).to_not be_new_record
    end
  end

  describe 'POST #create' do
    let(:user) { FactoryGirl.create :user, :with_investor }
    let(:attributes) { FactoryGirl.attributes_for :account }

    let(:integrator) do
      double.tap do |integrator|
        allow(integrator).to receive(:create_external_account)
        allow(integrator).to receive(:success?).and_return(true)
      end
    end

    before do
      log_in_as user

      allow(AccountIntegrator).to receive(:new).and_return(integrator)
    end

    it 'creates external account' do
      expect(AccountIntegrator).to receive(:new) do |account, params, ip|
        expect(account.investor.user).to eq(user)
        expect(params[:routing_number].to_i).to eq(attributes[:routing_number])
        expect(ip).to eq('0.0.0.0')
        integrator
      end

      expect(integrator).to receive(:create_external_account)

      post :create, account: attributes
    end

    it 'redirects to confirm_path if create external account is successful' do
      expect(integrator).to receive(:success?).and_return(true)
      post :create, account: attributes
      expect(response).to redirect_to(confirm_path)
    end

    context 'when create_external_account fails' do
      before do
        allow(integrator).to receive(:success?).and_return(false)
        allow(integrator).to receive(:error)
      end

      it 'renders billing_info_path' do
        expect(integrator).to receive(:success?).and_return(false)
        post :create, account: attributes
        expect(response).to render_template(:billing_info)
      end

      it 'assigns account so that errors are shown' do
        post :create, account: attributes
        expect(assigns[:account]).to be_an(Account)
      end

      it 'displays flash with error from integrator' do
        expect(integrator).to receive(:error).and_return('test error')
        post :create, account: attributes

        expect(flash.now[:danger]).to eq('test error')
      end
    end
  end
end
