describe AccountsController do
  describe 'GET #billing_info' do
    let(:account) { FactoryGirl.create :account }

    before { log_in_as account.user }

    it 'redirects to investments#confirm if account exists' do
      controller.current_user
    end
  end

  describe 'POST #create' do
  end
end
