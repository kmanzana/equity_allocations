describe Account do
  describe 'validations' do
    let(:investor) { FactoryGirl.create :investor }

    let(:account) do
      Account.new investor: investor, routing_number: 1234567890, account_number: 987654321
    end

    it 'is valid' do
      expect(account).to be_valid
    end

    it 'validates investor_id presence' do
      account.investor_id = nil
      expect(account).to_not be_valid
    end
  end
end
