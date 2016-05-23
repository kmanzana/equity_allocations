describe InvestorsController do

  describe 'GET #personal_info' do
    before { log_in_as FactoryGirl.create(:user) }

    it 'redirects to billing_info if investor exists in crowd_pay' do
      expect(controller.current_user).to receive(:investor_exists_in_crowd_pay?)
      .and_return(true)

      get :personal_info

      expect(response).to redirect_to(billing_info_path)
    end

    it 'renders template if investor does not exist in crowd_pay' do
      expect(controller.current_user).to receive(:investor_exists_in_crowd_pay?)
      .and_return(false)

      get :personal_info

      expect(response).to render_template(:personal_info)
    end

    it 'assigns investor for the view if investor does not exist' do
      expect(controller.current_user).to receive(:investor_exists_in_crowd_pay?)
      .and_return(false)

      get :personal_info

      expect(assigns[:investor]).to eq(controller.current_user.investor)
    end
  end

  describe 'POST #create' do
    let(:investor) { FactoryGirl.create :investor }
    let(:investor_params) { FactoryGirl.attributes_for :investor, :ready_for_crowd_pay }

    let(:integrator_mock) do
      mock = double
      allow(mock).to receive(:success?).and_return(true)
      allow(mock).to receive(:verify_and_create_external_investor)
      mock
    end

    before do
      log_in_as investor.user

      allow(InvestorIntegrator).to receive(:new).and_return(integrator_mock)
    end

    it 'attempts to verify and create the investor' do
      expect(integrator_mock).to receive(:verify_and_create_external_investor)

      expect(InvestorIntegrator).to receive(:new) do |investor, params, ip|
        expect(investor).to equal(controller.current_user.investor)
        expect(params[:first_name]).to eq(investor_params[:first_name])
        expect(params[:tax_id].to_i).to eq(investor_params[:tax_id])
        expect(ip).to eq('0.0.0.0')

        integrator_mock
      end

      post :create, investor: investor_params
    end

    it 'redirects to billing_info when verify and create succeed' do
      post :create, investor: investor_params

      expect(response).to redirect_to(billing_info_path)
    end

    context 'when investor verify and create fails' do
      before do
        allow(integrator_mock).to receive(:error).and_return('test error')
      end

      it 'renders personal_info' do
        allow(integrator_mock).to receive(:success?).and_return(false)

        post :create, investor: investor_params

        expect(response).to render_template(:personal_info)
      end

      it 'assigns investor for the view' do
        allow(integrator_mock).to receive(:success?).and_return(false)

        post :create, investor: investor_params

        expect(assigns[:investor]).to eq(investor)
      end

      it 'sets flash danger to integrator error' do
        allow(integrator_mock).to receive(:success?).and_return(false)
        allow(integrator_mock).to receive(:error).and_return('test error')

        post :create, investor: investor_params

        expect(flash.now[:danger]).to eq('test error')
      end
    end
  end
end
